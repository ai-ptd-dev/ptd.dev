require 'spec_helper'
require_relative '../../src/commands/version'

RSpec.describe PTD::Commands::Version do
  describe '#execute' do
    context 'with default output' do
      it 'displays formatted version information' do
        command = described_class.new

        expect { command.execute }.to output(/PTD Ruby CLI/).to_stdout
        expect { command.execute }.to output(/Version:.*1\.0\.0/).to_stdout
        expect { command.execute }.to output(/Build Date:.*2025-01-15/).to_stdout
        expect { command.execute }.to output(/Ruby Version:/).to_stdout
      end

      it 'displays a formatted box' do
        command = described_class.new
        output = capture_stdout { command.execute }

        expect(output).to include('╔')
        expect(output).to include('╚')
        expect(output).to include('║')
      end
    end

    context 'with JSON output' do
      it 'outputs valid JSON format' do
        command = described_class.new(json: true)
        output = capture_stdout { command.execute }

        json_data = JSON.parse(output)
        expect(json_data['name']).to eq('PTD Ruby CLI')
        expect(json_data['version']).to eq('1.0.0')
        expect(json_data['build_date']).to eq('2025-01-15')
        expect(json_data['repository']).to include('github.com')
      end

      it 'includes all required fields in JSON' do
        command = described_class.new(json: true)
        output = capture_stdout { command.execute }

        json_data = JSON.parse(output)
        required_fields = %w[name version build_date ruby_version platform description repository]

        required_fields.each do |field|
          expect(json_data).to have_key(field)
        end
      end
    end
  end

  describe 'constants' do
    it 'has correct version number' do
      expect(PTD::Commands::Version::VERSION).to eq('1.0.0')
    end

    it 'has build date' do
      expect(PTD::Commands::Version::BUILD_DATE).to eq('2025-01-15')
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
