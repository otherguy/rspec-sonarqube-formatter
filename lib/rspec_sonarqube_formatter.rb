# frozen_string_literal: true

require 'htmlentities'

class RspecSonarqubeFormatter
  attr_reader :output

  ::RSpec::Core::Formatters.register self,
    :start, :stop, :example_group_started, :example_started, :example_passed, :example_failed, :example_pending

  def initialize(output, xml_declaration: false)
    @output             = output
    @xml_declaration    = xml_declaration
    @current_file       = ''
    @last_failure_index = 0
  end

  def start(_notification)
    @output.puts '<?xml version="1.0" encoding="UTF-8"?>' if @xml_declaration
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
    # Convert to string and remove ANSI color codes
    cleaned = input.to_s.gsub(/\e\[\d;*\d*m/, '')

    # Convert any curly/smart quotes to straight quotes to prevent XML parsing issues
    # U+201C ("), U+201D ("), U+201E („) - various double quotes
    cleaned = cleaned.gsub(/[\u201C\u201D\u201E]/, '"')
    # U+2018 ('), U+2019 ('), U+201A (‚) - various single quotes
    cleaned = cleaned.gsub(/[\u2018\u2019\u201A]/, "'")

    # Encode using named HTML entities (&quot;, &apos;, &lt;, &gt;, &amp;)
    HTMLEntities.new.encode(cleaned, :named)
  end

  def duration(example)
    (example.execution_result.run_time.to_f * 1000).round
  end
end
