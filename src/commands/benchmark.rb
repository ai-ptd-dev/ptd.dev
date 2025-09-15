require 'benchmark'
require 'json'
require 'csv'
require 'tempfile'

module PTD
  module Commands
    class Benchmark
      def initialize(iterations, options = {})
        @iterations = iterations
        @output_format = options[:output] || 'console'
        @verbose = options[:verbose] || false
      end

      def execute
        puts "Running benchmarks with #{@iterations} iterations..." if @verbose

        results = run_benchmarks

        case @output_format
        when 'json'
          output_json(results)
        when 'csv'
          output_csv(results)
        else
          output_console(results)
        end
      end

      private

      def run_benchmarks
        results = {}

        # String manipulation benchmark
        results[:string_manipulation] = benchmark_string_manipulation

        # Array operations benchmark
        results[:array_operations] = benchmark_array_operations

        # File I/O benchmark
        results[:file_io] = benchmark_file_io

        # JSON parsing benchmark
        results[:json_parsing] = benchmark_json_parsing

        # Hash operations benchmark
        results[:hash_operations] = benchmark_hash_operations

        results
      end

      def benchmark_string_manipulation
        time = ::Benchmark.measure do
          @iterations.times do |i|
            str = "Hello World #{i}"
            str.upcase!
            str.reverse!
            str.gsub!(/[aeiou]/, '*')
            str.chars.join('-')
          end
        end

        {
          name: 'String Manipulation',
          iterations: @iterations,
          total_time: time.real,
          avg_time: time.real / @iterations,
          ops_per_sec: @iterations / time.real
        }
      end

      def benchmark_array_operations
        time = ::Benchmark.measure do
          @iterations.times do
            arr = (1..100).to_a
            arr.map! { |n| n * 2 }
            arr.select! { |n| (n % 3).zero? }
            arr.sort!.reverse!
            arr.reduce(:+)
          end
        end

        {
          name: 'Array Operations',
          iterations: @iterations,
          total_time: time.real,
          avg_time: time.real / @iterations,
          ops_per_sec: @iterations / time.real
        }
      end

      def benchmark_file_io
        time = nil
        Tempfile.create('benchmark') do |file|
          time = ::Benchmark.measure do
            @iterations.times do |i|
              file.rewind
              file.write("Line #{i}: #{'x' * 100}\n")
              file.flush
              file.rewind
              file.read
            end
          end
        end

        {
          name: 'File I/O',
          iterations: @iterations,
          total_time: time.real,
          avg_time: time.real / @iterations,
          ops_per_sec: @iterations / time.real
        }
      end

      def benchmark_json_parsing
        sample_data = {
          users: (1..10).map do |i|
            {
              id: i,
              name: "User #{i}",
              email: "user#{i}@example.com",
              metadata: {
                created_at: Time.now.to_s,
                tags: %w[ruby ptd cli benchmark]
              }
            }
          end
        }

        json_string = JSON.generate(sample_data)

        time = ::Benchmark.measure do
          @iterations.times do
            parsed = JSON.parse(json_string)
            JSON.generate(parsed)
          end
        end

        {
          name: 'JSON Parsing',
          iterations: @iterations,
          total_time: time.real,
          avg_time: time.real / @iterations,
          ops_per_sec: @iterations / time.real
        }
      end

      def benchmark_hash_operations
        time = ::Benchmark.measure do
          @iterations.times do
            hash = {}
            100.times { |i| hash["key_#{i}"] = i * 2 }
            hash.keys.sort
            hash.values.reduce(:+)
            hash.merge!(extra: 'data')
            hash.select { |_k, v| v.is_a?(Integer) && v > 50 }
          end
        end

        {
          name: 'Hash Operations',
          iterations: @iterations,
          total_time: time.real,
          avg_time: time.real / @iterations,
          ops_per_sec: @iterations / time.real
        }
      end

      def output_console(results)
        puts "\n#{'=' * 60}"
        puts "#{' ' * 20}BENCHMARK RESULTS"
        puts '=' * 60

        results.each_value do |result|
          puts "\n#{result[:name]}:"
          puts "  Iterations:     #{result[:iterations]}"
          puts "  Total time:     #{format_time(result[:total_time])}"
          puts "  Avg time/op:    #{format_time(result[:avg_time])}"
          puts "  Ops/second:     #{result[:ops_per_sec].round(2)}"
        end

        puts "\n#{'=' * 60}"
        puts "Total benchmark time: #{format_time(results.values.sum { |r| r[:total_time] })}"
        puts '=' * 60
      end

      def output_json(results)
        output = {
          timestamp: Time.now.iso8601,
          platform: RUBY_PLATFORM,
          ruby_version: RUBY_VERSION,
          benchmarks: results.map do |_, r|
            {
              name: r[:name],
              iterations: r[:iterations],
              total_time_ms: (r[:total_time] * 1000).round(3),
              avg_time_ms: (r[:avg_time] * 1000).round(6),
              ops_per_second: r[:ops_per_sec].round(2)
            }
          end
        }

        puts JSON.pretty_generate(output)
      end

      def output_csv(results)
        CSV do |csv|
          csv << ['Benchmark', 'Iterations', 'Total Time (s)', 'Avg Time (s)', 'Ops/Second']
          results.each_value do |r|
            csv << [
              r[:name],
              r[:iterations],
              r[:total_time].round(6),
              r[:avg_time].round(9),
              r[:ops_per_sec].round(2)
            ]
          end
        end
      end

      def format_time(seconds)
        if seconds < 0.001
          "#{(seconds * 1_000_000).round(2)} μs"
        elsif seconds < 1
          "#{(seconds * 1000).round(2)} ms"
        else
          "#{seconds.round(2)} s"
        end
      end
    end
  end
end
