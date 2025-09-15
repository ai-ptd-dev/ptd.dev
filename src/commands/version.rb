require 'json'

module PTD
  module Commands
    class Version
      VERSION = '1.0.0'.freeze
      BUILD_DATE = '2025-01-15'.freeze
      RUBY_VERSION = RUBY_VERSION

      def initialize(options = {})
        @json_output = options[:json] || false
      end

      def execute
        version_info = build_version_info

        if @json_output
          puts JSON.pretty_generate(version_info)
        else
          display_formatted(version_info)
        end
      end

      private

      def build_version_info
        {
          name: 'PTD Ruby CLI',
          version: VERSION,
          build_date: BUILD_DATE,
          ruby_version: RUBY_VERSION,
          platform: RUBY_PLATFORM,
          description: 'Polyglot Transpilation Development Reference Implementation',
          repository: 'https://github.com/ai-ptd-dev/ptd-ruby-cli'
        }
      end

      def display_formatted(info)
        puts '╔═══════════════════════════════════════════════════════════╗'
        puts '║                    PTD Ruby CLI                           ║'
        puts '╠═══════════════════════════════════════════════════════════╣'
        puts "║ Version:      #{info[:version].ljust(44)} ║"
        puts "║ Build Date:   #{info[:build_date].ljust(44)} ║"
        puts "║ Ruby Version: #{info[:ruby_version].ljust(44)} ║"
        puts "║ Platform:     #{info[:platform].ljust(44)} ║"
        puts '╠═══════════════════════════════════════════════════════════╣'
        puts "║ #{info[:description].center(57)} ║"
        puts '╚═══════════════════════════════════════════════════════════╝'
      end
    end
  end
end
