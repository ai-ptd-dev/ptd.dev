#!/usr/bin/env ruby

require 'thor'
require 'json'
require_relative 'commands/hello'
require_relative 'commands/version'
require_relative 'commands/benchmark'
require_relative 'utils/logger'

module PTD
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc 'hello NAME', 'Greet someone with a personalized message'
    option :uppercase, type: :boolean, aliases: '-u', desc: 'Print greeting in uppercase'
    option :repeat, type: :numeric, default: 1, aliases: '-r', desc: 'Repeat the greeting N times'
    def hello(name)
      command = Commands::Hello.new(name, options)
      command.execute
    end

    desc 'version', 'Display version information'
    option :json, type: :boolean, desc: 'Output version info as JSON'
    def version
      command = Commands::Version.new(options)
      command.execute
    end

    desc 'benchmark [ITERATIONS]', 'Run performance benchmarks'
    option :output, type: :string, default: 'console', desc: 'Output format: console, json, or csv'
    option :verbose, type: :boolean, aliases: '-v', desc: 'Show detailed benchmark information'
    def benchmark(iterations = 1000)
      command = Commands::Benchmark.new(iterations.to_i, options)
      command.execute
    end

    desc 'process FILE', 'Process a JSON file and demonstrate file I/O'
    option :pretty, type: :boolean, aliases: '-p', desc: 'Pretty print JSON output'
    option :stats, type: :boolean, aliases: '-s', desc: 'Show processing statistics'
    def process(file)
      logger = Utils::Logger.new(verbose: options[:stats])

      begin
        logger.info "Processing file: #{file}"

        unless File.exist?(file)
          logger.error "File not found: #{file}"
          exit 1
        end

        content = File.read(file)
        data = JSON.parse(content)

        logger.info "Successfully parsed JSON with #{data.keys.length} keys"

        if options[:pretty]
          puts JSON.pretty_generate(data)
        else
          puts data.to_json
        end

        if options[:stats]
          logger.info "File size: #{File.size(file)} bytes"
          logger.info 'Processing complete'
        end
      rescue JSON::ParserError => e
        logger.error "Invalid JSON: #{e.message}"
        exit 1
      rescue StandardError => e
        logger.error "Error: #{e.message}"
        exit 1
      end
    end
  end
end

PTD::CLI.start(ARGV) if __FILE__ == $PROGRAM_NAME
