# frozen_string_literal: true
require 'htmlentities'

class RspecSonarqubeFormatter
  ::RSpec::Core::Formatters.register self,
    :start, :stop, :example_group_started, :example_started, :example_passed, :example_failed, :example_pending

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
    @output.puts '  </file>' if @current_file != ''
    @output.puts '</testExecutions>'
  end

  def example_group_started(notification)
    return if notification.group.metadata[:file_path] == @current_file

    @output.puts '  </file>' if @current_file != ''
    @output.puts "  <file path=\"#{notification.group.metadata[:file_path]}\">"

    @current_file = notification.group.metadata[:file_path]
  end

  def example_started(_notification)
    # Do nothing
  end

  def example_passed(notification)
    @output.puts "    <testCase name=\"#{clean_string(notification.example.description)}\" duration=\"#{duration(notification.example)}\" />"
  end

  def example_failed(notification)
    @output.puts "    <testCase name=\"#{clean_string(notification.example.description)}\" duration=\"#{duration(notification.example)}\">"
    @output.puts "      <failure message=\"#{clean_string(notification.exception)}\" stacktrace=\"#{clean_string(notification.example.location)}\" />"
    @output.puts '    </testCase>'
  end

  def example_pending(notification)
    @output.puts "    <testCase name=\"#{clean_string(notification.example.description)}\" duration=\"#{duration(notification.example)}\">"
    @output.puts "      <skipped message=\"#{clean_string(notification.example.execution_result.pending_message)}\" />"
    @output.puts '    </testCase>'
  end

  def clean_string(input)
    HTMLEntities.new.encode input.to_s.gsub(/\e\[\d;*\d*m/, '').tr('"', "'")
  end

  def duration(example)
    (example.execution_result.run_time.to_f * 1000).round
  end
end
