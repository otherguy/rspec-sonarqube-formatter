# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name = 'rspec-sonarqube-formatter'

  spec.version  = '1.6.5.pre'
  spec.platform = Gem::Platform::RUBY
  spec.authors  = ['Alexander Graf']
  spec.email    = ['alex@otherguy.uo']

  spec.metadata = {
    'bug_tracker_uri'       => 'https://github.com/otherguy/rspec-sonarqube-formatter/issues',
    'source_code_uri'       => 'https://github.com/otherguy/rspec-sonarqube-formatter',
    'rubygems_mfa_required' => 'true'
  }

  spec.summary     = 'Generic test data formatter for SonarQube'
  spec.description = 'Generates an XML report that the SonarQube Generic Test Data parser can understand'
  spec.homepage    = 'https://github.com/otherguy/rspec-sonarqube-formatter'
  spec.license     = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.1'

  spec.add_dependency 'htmlentities', '~> 4.3'
  spec.add_dependency 'rspec',        '~> 3.0'
end
