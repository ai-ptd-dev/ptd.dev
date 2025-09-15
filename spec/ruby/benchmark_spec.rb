require 'spec_helper'
require_relative '../../src/commands/benchmark'

RSpec.describe PTD::Commands::Benchmark do
  describe '#execute' do
    let(:iterations) { 10 } # Use small number for tests

    context 'with console output' do
      it 'displays benchmark results' do
        command = described_class.new(iterations)

        expect { command.execute }.to output(/BENCHMARK RESULTS/).to_stdout
        expect { command.execute }.to output(/String Manipulation/).to_stdout
        expect { command.execute }.to output(/Array Operations/).to_stdout
        expect { command.execute }.to output(%r{File I/O}).to_stdout
        expect { command.execute }.to output(/JSON Parsing/).to_stdout
        expect { command.execute }.to output(/Hash Operations/).to_stdout
      end

      it 'shows performance metrics' do
        command = described_class.new(iterations)
        output = capture_stdout { command.execute }

        expect(output).to include('Iterations:')
        expect(output).to include('Total time:')
        expect(output).to include('Avg time/op:')
        expect(output).to include('Ops/second:')
      end

      it 'displays total benchmark time' do
        command = described_class.new(iterations)

        expect { command.execute }.to output(/Total benchmark time:/).to_stdout
      end
    end

    context 'with JSON output' do
      it 'outputs valid JSON format' do
        command = described_class.new(iterations, output: 'json')
        output = capture_stdout { command.execute }

        json_data = JSON.parse(output)
        expect(json_data).to have_key('timestamp')
        expect(json_data).to have_key('platform')
        expect(json_data).to have_key('ruby_version')
        expect(json_data).to have_key('benchmarks')
      end

      it 'includes all benchmark results in JSON' do
        command = described_class.new(iterations, output: 'json')
        output = capture_stdout { command.execute }

        json_data = JSON.parse(output)
        benchmarks = json_data['benchmarks']

        expect(benchmarks).to be_an(Array)
        expect(benchmarks.size).to eq(5)

        benchmark_names = benchmarks.map { |b| b['name'] }
        expect(benchmark_names).to include('String Manipulation')
        expect(benchmark_names).to include('Array Operations')
        expect(benchmark_names).to include('File I/O')
        expect(benchmark_names).to include('JSON Parsing')
        expect(benchmark_names).to include('Hash Operations')
      end

      it 'includes timing data for each benchmark' do
        command = described_class.new(iterations, output: 'json')
        output = capture_stdout { command.execute }

        json_data = JSON.parse(output)
        benchmarks = json_data['benchmarks']

        benchmarks.each do |benchmark|
          expect(benchmark).to have_key('iterations')
          expect(benchmark).to have_key('total_time_ms')
          expect(benchmark).to have_key('avg_time_ms')
          expect(benchmark).to have_key('ops_per_second')
        end
      end
    end

    context 'with CSV output' do
      it 'outputs CSV format with headers' do
        command = described_class.new(iterations, output: 'csv')
        output = capture_stdout { command.execute }

        lines = output.split("\n")
        expect(lines.first).to include('Benchmark,Iterations,Total Time')
        expect(lines.size).to be > 1
      end
    end

    context 'with verbose option' do
      it 'shows running message' do
        command = described_class.new(iterations, verbose: true)

        expect { command.execute }.to output(/Running benchmarks with \d+ iterations/).to_stdout
      end
    end

    describe 'benchmark methods' do
      let(:command) { described_class.new(iterations) }

      it 'performs string manipulation benchmark' do
        result = command.send(:benchmark_string_manipulation)

        expect(result[:name]).to eq('String Manipulation')
        expect(result[:iterations]).to eq(iterations)
        expect(result[:total_time]).to be_a(Float)
        expect(result[:avg_time]).to be_a(Float)
        expect(result[:ops_per_sec]).to be > 0
      end

      it 'performs array operations benchmark' do
        result = command.send(:benchmark_array_operations)

        expect(result[:name]).to eq('Array Operations')
        expect(result[:total_time]).to be_a(Float)
      end

      it 'performs file I/O benchmark' do
        result = command.send(:benchmark_file_io)

        expect(result[:name]).to eq('File I/O')
        expect(result[:total_time]).to be_a(Float)
      end

      it 'performs JSON parsing benchmark' do
        result = command.send(:benchmark_json_parsing)

        expect(result[:name]).to eq('JSON Parsing')
        expect(result[:total_time]).to be_a(Float)
      end

      it 'performs hash operations benchmark' do
        result = command.send(:benchmark_hash_operations)

        expect(result[:name]).to eq('Hash Operations')
        expect(result[:total_time]).to be_a(Float)
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
