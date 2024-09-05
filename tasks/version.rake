# frozen_string_literal: true

require 'rubygems'

desc 'Bump version of this gem'
task :version, [:version] do |_task, args|
  args.with_defaults(version: nil)

  gemspec_file_path = 'rspec-sonarqube-formatter.gemspec'

  spec = Gem::Specification.load(gemspec_file_path)
  current_version = spec.version.to_s

  if args[:version].nil?
    puts "Version: #{current_version}"
    exit 0
  end

  unless /(\d+)\.(\d+)\.(\d+)/.match?(args[:version])
    puts "#{args[:version]} needs to be a major/minor/patch SemVer version number!"
    exit 1
  end

  version_pattern = /spec.version\s+= '(.+)'/

  # Read the current version from file
  content = File.read(gemspec_file_path)

  unless content.match(version_pattern)
    puts "Error in #{version_file_path} file! Cannot determine current version!"
    exit 1
  end

  puts "Updating gem version from #{current_version} to #{args[:version]}..."
  File.open(gemspec_file_path, 'w') do |file|
    file.puts content.sub(version_pattern, %(spec.version  = '#{args[:version]}'))
  end

  puts "Version set to #{args[:version]}"
end
