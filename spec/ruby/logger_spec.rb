require 'spec_helper'
require_relative '../../src/utils/logger'

RSpec.describe PTD::Utils::Logger do
  let(:output) { StringIO.new }
  let(:logger) { described_class.new(output: output, use_colors: false) }

  describe '#initialize' do
    it 'sets default log level to info' do
      expect(logger.level).to eq(:info)
    end

    it 'sets log level to debug when verbose is true' do
      verbose_logger = described_class.new(verbose: true, output: output)
      expect(verbose_logger.level).to eq(:debug)
    end

    it 'detects TTY for color support' do
      tty_output = StringIO.new
      allow(tty_output).to receive(:tty?).and_return(true)

      color_logger = described_class.new(output: tty_output)
      expect(color_logger.use_colors).to be true
    end
  end

  describe 'logging methods' do
    it 'logs debug messages when level is debug' do
      logger.level = :debug
      logger.debug('Debug message')

      expect(output.string).to include('DEBUG')
      expect(output.string).to include('Debug message')
    end

    it 'logs info messages' do
      logger.info('Info message')

      expect(output.string).to include('INFO')
      expect(output.string).to include('Info message')
    end

    it 'logs warning messages' do
      logger.warn('Warning message')

      expect(output.string).to include('WARN')
      expect(output.string).to include('Warning message')
    end

    it 'logs error messages' do
      logger.error('Error message')

      expect(output.string).to include('ERROR')
      expect(output.string).to include('Error message')
    end

    it 'logs fatal messages' do
      logger.fatal('Fatal message')

      expect(output.string).to include('FATAL')
      expect(output.string).to include('Fatal message')
    end

    it 'includes metadata in log output' do
      logger.info('Message', user_id: 123, action: 'login')

      expect(output.string).to include('user_id=123')
      expect(output.string).to include('action="login"')
    end

    it 'respects log level filtering' do
      logger.level = :warn

      logger.debug('Debug')
      logger.info('Info')
      logger.warn('Warning')

      expect(output.string).not_to include('Debug')
      expect(output.string).not_to include('Info')
      expect(output.string).to include('Warning')
    end
  end

  describe '#with_timing' do
    it 'logs start and completion messages' do
      logger.with_timing('Task') { sleep 0.01 }

      expect(output.string).to include('Starting: Task')
      expect(output.string).to include('Completed: Task')
    end

    it 'includes duration in completion message' do
      logger.with_timing('Quick task') { sleep 0.01 }

      expect(output.string).to match(/Completed: Quick task \(\d+(\.\d+)?ms\)/)
    end

    it 'logs error and re-raises on failure' do
      expect do
        logger.with_timing('Failing task') { raise 'Test error' }
      end.to raise_error('Test error')

      expect(output.string).to include('Failed: Failing task')
      expect(output.string).to include('Test error')
    end

    it 'returns the block result' do
      result = logger.with_timing('Task') { 42 }
      expect(result).to eq(42)
    end
  end

  describe '#progress' do
    it 'displays progress bar' do
      logger.progress(50, 100, 'Loading')

      expect(output.string).to include('Loading:')
      expect(output.string).to include('[')
      expect(output.string).to include(']')
      expect(output.string).to include('50.0%')
      expect(output.string).to include('(50/100)')
    end

    it 'shows filled and unfilled portions' do
      logger.progress(30, 100, 'Processing')

      # Should have some filled blocks and some unfilled
      expect(output.string).to include('█')
      expect(output.string).to include('░')
    end

    it 'adds newline when complete' do
      output.string = ''
      logger.progress(100, 100, 'Done')

      expect(output.string).to end_with("\n")
    end
  end

  describe 'color support' do
    let(:color_logger) do
      tty_output = StringIO.new
      allow(tty_output).to receive(:tty?).and_return(true)
      described_class.new(output: tty_output, use_colors: true)
    end

    it 'includes ANSI color codes when colors are enabled' do
      color_logger.info('Colored message')

      expect(color_logger.instance_variable_get(:@output).string).to include("\e[")
    end
  end

  describe 'timestamp formatting' do
    it 'includes ISO8601 timestamp' do
      logger.info('Test')

      # Check for ISO8601 format pattern
      expect(output.string).to match(/\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
    end
  end
end

RSpec.describe PTD::Utils::FileLogger do
  let(:temp_file) { Tempfile.new('test.log') }
  let(:file_logger) { described_class.new(temp_file.path) }

  after do
    temp_file.close
    temp_file.unlink
  end

  it 'writes logs to file' do
    file_logger.info('File log message')

    content = File.read(temp_file.path)
    expect(content).to include('File log message')
  end

  it 'does not use colors in file output' do
    file_logger.info('No colors')

    content = File.read(temp_file.path)
    expect(content).not_to include("\e[")
  end
end

RSpec.describe PTD::Utils::MultiLogger do
  let(:output1) { StringIO.new }
  let(:output2) { StringIO.new }
  let(:logger1) { PTD::Utils::Logger.new(output: output1, use_colors: false) }
  let(:logger2) { PTD::Utils::Logger.new(output: output2, use_colors: false) }
  let(:multi_logger) { described_class.new(logger1, logger2) }

  it 'logs to all configured loggers' do
    multi_logger.info('Multi message')

    expect(output1.string).to include('Multi message')
    expect(output2.string).to include('Multi message')
  end

  it 'supports all log levels' do
    %i[debug info warn error fatal].each do |level|
      logger1.level = :debug
      logger2.level = :debug

      multi_logger.send(level, "#{level} message")

      expect(output1.string).to include(level.to_s.upcase.to_s)
      expect(output2.string).to include(level.to_s.upcase.to_s)
    end
  end

  it 'delegates with_timing to first logger' do
    result = multi_logger.with_timing('Task') { 42 }

    expect(result).to eq(42)
    expect(output1.string).to include('Starting: Task')
    expect(output1.string).to include('Completed: Task')
  end
end
