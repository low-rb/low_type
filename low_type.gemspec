# frozen_string_literal: true

require_relative 'lib/version'

Gem::Specification.new do |spec|
  spec.name = 'low_type'
  spec.version = LowType::VERSION
  spec.authors = ['maedi']
  spec.email = ['maediprichard@gmail.com']

  spec.summary = 'An elegant way to define types in Ruby'
  spec.description = 'An elegant and simple way to define types in Ruby, only when you need them.'
  spec.homepage = 'https://codeberg.org/low_ruby/low_type'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://codeberg.org/low_ruby/low_type/src/branch/main'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)

  spec.files = [
    'lib/version.rb',
    'lib/low_type.rb',
    'lib/param_proxy.rb',
    'lib/parser.rb',
    'lib/type_expression.rb',
  ]

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency 'example-gem', '~> 1.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
