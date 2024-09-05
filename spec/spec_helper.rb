# frozen_string_literal: true

require 'simplecov'
require 'simplecov_json_formatter'
require 'simplecov-html'
require 'simplecov-lcov'

SimpleCov::Formatter::LcovFormatter.config do |c|
  c.single_report_path = 'coverage/lcov.info'
  c.report_with_single_file = true
end

# Code coverage
SimpleCov.start do
  # ignore common ruby and ruby on rails files in test coverage
  add_filter 'Gemfile'

  # Ignore Specs/tests themselves
  add_filter 'spec'

  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::JSONFormatter,
    SimpleCov::Formatter::LcovFormatter
  ])

  # Track Ruby files
  track_files 'lib/**/*.rb'

  # Enable branch coverage
  enable_coverage :branch
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata.
  config.filter_run_when_matching :focus
  config.run_all_when_everything_filtered = true
  config.filter_run_excluding :exclude

  # Raise errors for deprecated interfaces
  config.raise_errors_for_deprecations!

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Configure the test run order.
  config.order = :defined # :random
end
