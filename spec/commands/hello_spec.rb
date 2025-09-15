require 'spec_helper'
require_relative '../../src/commands/hello'

RSpec.describe BasicCli::Commands::Hello do
  describe '#execute' do
    it 'greets the user with their name' do
      command = described_class.new('Alice')

      expect { command.execute }.to output(/Alice/).to_stdout
      expect { command.execute }.to output(/Welcome to BasicCli/).to_stdout
    end

    it 'includes time-based greeting' do
      command = described_class.new('Bob')

      expect { command.execute }.to output(/Good (morning|afternoon|evening)/).to_stdout
    end

    context 'with uppercase option' do
      it 'outputs greeting in uppercase' do
        command = described_class.new('Charlie', uppercase: true)
        output = capture_stdout { command.execute }

        expect(output).to eq(output.upcase)
        expect(output).to include('CHARLIE')
      end
    end

    context 'with repeat option' do
      it 'repeats the greeting specified number of times' do
        command = described_class.new('David', repeat: 3)
        output = capture_stdout { command.execute }

        lines = output.split("\n")
        expect(lines.size).to eq(3)
        expect(lines).to all(include('David'))
      end
    end

    it 'returns a successful result object' do
      command = described_class.new('Eve')

      result = nil
      capture_stdout { result = command.execute }

      expect(result).to be_success
      expect(result.success).to be true
      expect(result.message).to include('Eve')
    end

    context 'time of day detection' do
      it 'returns appropriate greeting based on hour' do
        command = described_class.new('Test')

        # We can't easily mock Time.now without additional gems,
        # so we just verify it returns one of the valid greetings
        allow(Time).to receive(:now).and_return(Time.parse('09:00'))
        expect { command.execute }.to output(/Good morning/).to_stdout

        allow(Time).to receive(:now).and_return(Time.parse('14:00'))
        expect { command.execute }.to output(/Good afternoon/).to_stdout

        allow(Time).to receive(:now).and_return(Time.parse('20:00'))
        expect { command.execute }.to output(/Good evening/).to_stdout
      end
    end
  end

  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
