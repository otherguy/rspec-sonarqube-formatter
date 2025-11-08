# frozen_string_literal: true

require 'rspec_sonarqube_formatter'

RSpec.describe RspecSonarqubeFormatter, type: :helper do
  before :each do
    @output = StringIO.new

    @formatter = RspecSonarqubeFormatter.new(@output)
    @example   = RSpec::Core::ExampleGroup.describe.example_group 'anonymous group', :exclude

    @notification = RSpec::Core::Notifications::GroupNotification.new @example.example

    @formatter.start(2)
    @formatter.example_group_started(@notification)
    @formatter.example_started(@example)
  end

  it 'loads the RspecSonarqubeFormatter class' do
    expect(RspecSonarqubeFormatter.name).to eq('RspecSonarqubeFormatter')
  end

  describe 'passing example' do
    before :each do
      @formatter.example_passed(@example)
      @formatter.stop(@example)
      @output.rewind

      @output = @output.read.strip
    end

    it 'is expected to start with testExecutions and not include XML declaration by default' do
      expect(@output).to start_with '<testExecutions version="1">'
      expect(@output).to end_with '</testExecutions>'
      expect(@output).not_to include '<?xml version="1.0" encoding="UTF-8"?>'
    end

    it 'is expected to have a testExecutions section' do
      expect(@output).to match '<testExecutions version="1">'
    end

    it 'is expected to end the testExecutions section' do
      expect(@output).to end_with '</testExecutions>'
    end

    it 'is expected to contain a file section' do
      expect(@output).to match '<file path=".+">'
    end

    it 'is expected to contain a testCase' do
      expect(@output).to match '<testCase name=".*" duration="[\d]+" />'
    end

    it 'is expected to end the file section' do
      expect(@output).to match '</file>'
    end
  end

  describe 'failing example' do
    before :each do
      @notification = RSpec::Core::Notifications::FailedExampleNotification.new @example.example

      @formatter.example_failed(@notification)
      @formatter.stop(@example)
      @output.rewind

      @output = @output.read.strip
    end

    it 'is expected to start with testExecutions and not include XML declaration by default' do
      expect(@output).to start_with '<testExecutions version="1">'
      expect(@output).to end_with '</testExecutions>'
      expect(@output).not_to include '<?xml version="1.0" encoding="UTF-8"?>'
    end

    it 'is expected to have a testExecutions section' do
      expect(@output).to match '<testExecutions version="1">'
    end

    it 'is expected to end the testExecutions section' do
      expect(@output).to end_with '</testExecutions>'
    end

    it 'is expected to contain a file section' do
      expect(@output).to match '<file path=".+">'
    end

    it 'is expected to contain a testCase' do
      expect(@output).to match '<testCase name=".*" duration="[\d]+">'
    end

    it 'is expected to contain a failure message' do
      expect(@output).to match '<failure message=".*" stacktrace=".+" />'
    end

    it 'is expected to end the testCase' do
      expect(@output).to match '</testCase>'
    end

    it 'is expected to end the file section' do
      expect(@output).to match '</file>'
    end
  end

  describe 'pending example' do
    before :each do
      @notification = RSpec::Core::Notifications::PendingExampleFailedAsExpectedNotification.new @example.example

      @formatter.example_pending(@notification)
      @formatter.stop(@example)
      @output.rewind

      @output = @output.read.strip
    end

    it 'is expected to start with testExecutions and not include XML declaration by default' do
      expect(@output).to start_with '<testExecutions version="1">'
      expect(@output).to end_with '</testExecutions>'
      expect(@output).not_to include '<?xml version="1.0" encoding="UTF-8"?>'
    end

    it 'is expected to have a testExecutions section' do
      expect(@output).to match '<testExecutions version="1">'
    end

    it 'is expected to end the testExecutions section' do
      expect(@output).to end_with '</testExecutions>'
    end

    it 'is expected to contain a file section' do
      expect(@output).to match '<file path=".+">'
    end

    it 'is expected to contain a testCase' do
      expect(@output).to match '<testCase name=".*" duration="[\d]+">'
    end

    it 'is expected to contain a skipped message' do
      expect(@output).to match '<skipped message=".*" />'
    end

    it 'is expected to end the testCase' do
      expect(@output).to match '</testCase>'
    end

    it 'is expected to end the file section' do
      expect(@output).to match '</file>'
    end
  end

  describe 'XML declaration option' do
    it 'includes XML declaration when xml_declaration is true' do
      output = StringIO.new
      formatter = RspecSonarqubeFormatter.new(output, xml_declaration: true)
      example = RSpec::Core::ExampleGroup.describe.example_group('test group', :exclude)
      notification = RSpec::Core::Notifications::GroupNotification.new example.example

      formatter.start(2)
      formatter.example_group_started(notification)
      formatter.example_passed(example)
      formatter.stop(example)
      output.rewind

      result = output.read.strip
      expect(result).to start_with '<?xml version="1.0" encoding="UTF-8"?>'
    end

    it 'does not include XML declaration when xml_declaration is false' do
      output = StringIO.new
      formatter = RspecSonarqubeFormatter.new(output, xml_declaration: false)
      example = RSpec::Core::ExampleGroup.describe.example_group('test group', :exclude)
      notification = RSpec::Core::Notifications::GroupNotification.new example.example

      formatter.start(2)
      formatter.example_group_started(notification)
      formatter.example_passed(example)
      formatter.stop(example)
      output.rewind

      result = output.read.strip
      expect(result).to start_with '<testExecutions version="1">'
      expect(result).not_to include '<?xml version="1.0" encoding="UTF-8"?>'
    end
  end

  describe 'quote handling in clean_string method' do
    let(:formatter) { RspecSonarqubeFormatter.new(StringIO.new) }

    it 'converts curly double quotes to straight quotes then encodes them' do
      # Using Unicode escape sequences: \u201C = " and \u201D = "
      input = "\u201Ccurly\u201D quotes"
      result = formatter.clean_string(input)

      # Should not contain curly quotes
      expect(result).not_to include "\u201C"
      expect(result).not_to include "\u201D"
      # Should contain HTML entities for straight quotes
      expect(result).to include '&quot;'
    end

    it 'converts curly single quotes to straight quotes then encodes them' do
      # Using Unicode escape sequences: \u2018 = ' and \u2019 = '
      input = "\u2018curly\u2019 quotes"
      result = formatter.clean_string(input)

      # Should not contain curly quotes
      expect(result).not_to include "\u2018"
      expect(result).not_to include "\u2019"
      # Should contain HTML entities for straight quotes
      expect(result).to include '&apos;'
    end

    it 'encodes straight double quotes as HTML entities using :named encoding' do
      input = 'test with "quotes"'
      result = formatter.clean_string(input)

      expect(result).to include '&quot;'
      expect(result).not_to include '"'  # Raw quote should be encoded
    end

    it 'encodes straight single quotes as HTML entities using :named encoding' do
      input = "test with 'apostrophes'"
      result = formatter.clean_string(input)

      expect(result).to include '&apos;'
      expect(result).not_to include "'"  # Raw quote should be encoded (except in &apos;)
    end

    it 'properly escapes special XML characters' do
      input = 'test with <tag> & "quotes"'
      result = formatter.clean_string(input)

      # Should escape all special XML characters using named entities
      expect(result).to include '&lt;'
      expect(result).to include '&gt;'
      expect(result).to include '&amp;'
      expect(result).to include '&quot;'
    end

    it 'removes ANSI color codes' do
      input = "\e[31mred text\e[0m"
      result = formatter.clean_string(input)

      expect(result).not_to include "\e["
      expect(result).to eq 'red text'
    end

    it 'handles mixed curly and straight quotes' do
      input = "\u201Ccurly\u201D and \"straight\" quotes"
      result = formatter.clean_string(input)

      # Should not contain curly quotes
      expect(result).not_to include "\u201C"
      expect(result).not_to include "\u201D"
      # Should contain encoded straight quotes
      expect(result).to include '&quot;'
    end
  end
end
