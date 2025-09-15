require 'time'

module PTD
  module Utils
    class Logger
      LEVELS = {
        debug: 0,
        info: 1,
        warn: 2,
        error: 3,
        fatal: 4
      }.freeze

      COLORS = {
        debug: "\e[36m",  # Cyan
        info: "\e[32m",   # Green
        warn: "\e[33m",   # Yellow
        error: "\e[31m",  # Red
        fatal: "\e[35m",  # Magenta
        reset: "\e[0m"
      }.freeze

      attr_accessor :level, :use_colors

      def initialize(level: :info, verbose: false, use_colors: true, output: $stdout)
        @level = verbose ? :debug : level
        @use_colors = use_colors && output.tty?
        @output = output
        @mutex = Mutex.new
      end

      def debug(message, metadata = {})
        log(:debug, message, metadata)
      end

      def info(message, metadata = {})
        log(:info, message, metadata)
      end

      def warn(message, metadata = {})
        log(:warn, message, metadata)
      end

      def error(message, metadata = {})
        log(:error, message, metadata)
      end

      def fatal(message, metadata = {})
        log(:fatal, message, metadata)
      end

      def with_timing(message)
        start_time = Time.now
        info("Starting: #{message}")

        result = yield

        elapsed = Time.now - start_time
        info("Completed: #{message} (#{format_duration(elapsed)})")

        result
      rescue StandardError => e
        elapsed = Time.now - start_time
        error("Failed: #{message} (#{format_duration(elapsed)}) - #{e.message}")
        raise
      end

      def progress(current, total, message = 'Progress')
        percentage = (current.to_f / total * 100).round(1)
        bar_length = 30
        filled = (bar_length * (current.to_f / total)).round

        bar = ('█' * filled) + ('░' * (bar_length - filled))

        @mutex.synchronize do
          @output.print "\r#{message}: [#{bar}] #{percentage}% (#{current}/#{total})"
          @output.print "\n" if current >= total
        end
      end

      private

      def log(severity, message, metadata = {})
        return if LEVELS[severity] < LEVELS[@level]

        timestamp = Time.now.iso8601
        formatted_message = format_message(severity, timestamp, message, metadata)

        @mutex.synchronize do
          @output.puts formatted_message
        end
      end

      def format_message(severity, timestamp, message, metadata)
        severity_str = severity.to_s.upcase.ljust(5)

        if @use_colors
          severity_color = COLORS[severity]
          reset_color = COLORS[:reset]
          formatted = "#{severity_color}[#{timestamp}] #{severity_str}#{reset_color} | #{message}"
        else
          formatted = "[#{timestamp}] #{severity_str} | #{message}"
        end

        formatted += " | #{format_metadata(metadata)}" unless metadata.empty?

        formatted
      end

      def format_metadata(metadata)
        metadata.map { |k, v| "#{k}=#{v.inspect}" }.join(' ')
      end

      def format_duration(seconds)
        if seconds < 1
          "#{(seconds * 1000).round(2)}ms"
        elsif seconds < 60
          "#{seconds.round(2)}s"
        else
          minutes = (seconds / 60).floor
          secs = (seconds % 60).round
          "#{minutes}m #{secs}s"
        end
      end
    end

    class FileLogger < Logger
      def initialize(filename, **options)
        file = File.open(filename, 'a')
        file.sync = true
        super(**options.merge(output: file, use_colors: false))

        at_exit { file.close unless file.closed? }
      end
    end

    class MultiLogger
      def initialize(*loggers)
        @loggers = loggers
      end

      %i[debug info warn error fatal].each do |level|
        define_method(level) do |message, metadata = {}|
          @loggers.each { |logger| logger.send(level, message, metadata) }
        end
      end

      def with_timing(message, &block)
        @loggers.first.with_timing(message, &block)
      end

      def progress(current, total, message = 'Progress')
        @loggers.each { |logger| logger.progress(current, total, message) }
      end
    end
  end
end
