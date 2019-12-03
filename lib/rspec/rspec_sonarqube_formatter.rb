# frozen_string_literal: true

require 'rspec_sonarqube_formatter/version'

module RSpec
  module RspecSonarqubeFormatter
    class Formatter
      RSpec::Core::Formatters.register self,
        :start,
        :dump_failures,
        :example_failed,
        :example_passed,
        :example_skipped,
        :message

      def initialize(output)
        @output = output
      end

      def start(notification)
        @output.puts 'in start'
        @output.puts notification.fully_formatted
        @output.puts
      end

      def dump_failure(notification)
        @output.puts 'in dump_failure'
        @output.puts notification.fully_formatted
        @output.puts
      end

      def example_failed(notification)
        @output.puts 'in example_failed'
        @output.puts notification.fully_formatted
        @output.puts
      end

      def example_passed(notification)
        @output.puts 'in example_passed'
        @output.puts notification.fully_formatted
        @output.puts
      end

      def example_skipped(notification)
        @output.puts 'in example_skipped'
        @output.puts notification.fully_formatted
        @output.puts
      end

      def message(notification)
        @output.puts 'in message'
        @output.puts notification.fully_formatted
        @output.puts
      end
    end
  end
end
