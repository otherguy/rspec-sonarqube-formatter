# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'rspec-sonarqube-formatter'

  # rubocop:disable Gemspec/DuplicatedAssignment
  spec.version       = '1.0.0-local'
  spec.version       = ENV.fetch('TRAVIS_TAG') { spec.version }.to_s if ENV['TRAVIS']
  # rubocop:enable Gemspec/DuplicatedAssignment

  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ['Alexander Graf']
  spec.email         = ['alex@otherguy.uo']

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/otherguy/rspec-sonarqube-formatter/issues',
    'source_code_uri' => 'https://github.com/otherguy/rspec-sonarqube-formatter'
  }

  spec.summary       = 'Generic test data formatter for SonarQube'
  spec.description   = 'Generates an XML report that the SonarQube Generic Test Data parser can understand'
  spec.homepage      = 'https://github.com/otherguy/rspec-sonarqube-formatter'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4.0'

  spec.add_dependency 'htmlentities', '~> 4.3.3'
  spec.add_dependency 'rspec',        '~> 3.0'

  spec.add_development_dependency 'bundler',        '~> 2.1.0'
  spec.add_development_dependency 'coveralls',      '~> 0.8.23'
  spec.add_development_dependency 'rake',           '~> 13.0.1'
  spec.add_development_dependency 'rubocop',        '~> 0.88.0'
  spec.add_development_dependency 'simplecov',      '~> 0.16.1'
  spec.add_development_dependency 'simplecov-json', '~> 0.2.0'
end
