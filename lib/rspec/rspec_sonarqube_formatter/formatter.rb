# frozen_string_literal: true

require 'rspec_sonarqube_formatter/version'

module RSpec
  module RspecSonarqubeFormatter
    class Formatter
      RSpec::Core::Formatters.register self,
        :start,
        :stop,
        :example_group_started,
        :example_failed,
        :example_passed,
        :example_pending,
        :message

      def initialize(output)
        @output             = output
        @current_file       = ''
        @last_failure_index = 0
      end

      def start(_notification)
        @output.puts '<?xml version="1.0" encoding="UTF-8"?>'
        @output.puts '<testExecutions version="1">'
      end

      def stop(_notification)
        @output.puts '  </file>'
        @output.puts '</testExecutions>'
      end

      def example_group_started(notification)
        return if notification.group.metadata[:file_path] == @current_file

        @output.puts '  </file>' if @current_file != ''
        @output.puts "  <file path=\"#{notification.group.metadata[:file_path]}\">"
        @current_file = notification.group.metadata[:file_path]
      end

      def example_failed(notification)
        @output.puts "    <testCase name=\"#{clean_string(notification.example.description)}\" duration=\"#{notification.example.execution_result.run_time.in_milliseconds.round}\">"
        @output.puts "      <failure message=\"#{notification.exception}\" stacktrace=\"#{notification.example.location}\"/>"
        @output.puts '    </testCase>'
      end

      def example_passed(notification)
        @output.puts "    <testCase name=\"#{clean_string(notification.example.description)}\" duration=\"#{notification.example.execution_result.run_time.in_milliseconds.round}\"/>"
      end

      def example_pending(notification)
        @output.puts "    <testCase name=\"#{clean_string(notification.example.description)}\" duration=\"#{notification.example.execution_result.run_time.in_milliseconds.round}\">"
        @output.puts "      <skipped message=\"#{clean_string(notification.example.execution_result.pending_message)}\"/>"
        @output.puts '    </testCase>'
      end

      def clean_string(input)
        input.gsub(/\e\[\d;*\d*m/, '').tr('"', "'")
      end
    end
  end
end
