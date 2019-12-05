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

    it 'is expected to start with an XML header' do
      expect(@output).to start_with '<?xml version="1.0" encoding="UTF-8"?>'
      expect(@output).to match '<testExecutions version="1">'
      expect(@output).to end_with '</testExecutions>'
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

    it 'is expected to start with an XML header' do
      expect(@output).to start_with '<?xml version="1.0" encoding="UTF-8"?>'
      expect(@output).to match '<testExecutions version="1">'
      expect(@output).to end_with '</testExecutions>'
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

    it 'is expected to start with an XML header' do
      expect(@output).to start_with '<?xml version="1.0" encoding="UTF-8"?>'
      expect(@output).to match '<testExecutions version="1">'
      expect(@output).to end_with '</testExecutions>'
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
end
