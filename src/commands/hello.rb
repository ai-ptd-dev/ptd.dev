module BasicCli
  module Commands
    class Hello
      def initialize(name, options = {})
        @name = name
        @uppercase = options[:uppercase] || false
        @repeat = options[:repeat] || 1
      end

      def execute
        greeting = build_greeting

        @repeat.times do |_i|
          if @uppercase
            puts greeting.upcase
          else
            puts greeting
          end
        end

        Result.new(success: true, message: greeting)
      rescue StandardError => e
        Result.new(success: false, message: e.message)
      end

      private

      def build_greeting
        time_of_day_greeting = time_of_day
        "#{time_of_day_greeting}, #{@name}! Welcome to BasicCli"
      end

      def time_of_day
        hour = Time.now.hour
        case hour
        when 0..11
          'Good morning'
        when 12..17
          'Good afternoon'
        else
          'Good evening'
        end
      end

      class Result
        attr_reader :success, :message

        def initialize(success:, message:)
          @success = success
          @message = message
        end

        def success?
          @success
        end
      end
    end
  end
end
