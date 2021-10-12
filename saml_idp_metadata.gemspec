# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'saml_idp_metadata/version'

Gem::Specification.new do |spec|
  spec.name                  = 'saml_idp_metadata'
  spec.required_ruby_version = '>= 2.6', '< 4'
  spec.version               = SamlIdpMetadata::VERSION
  spec.authors               = ['tknzk']
  spec.email                 = ['tkm.knzk@gmail.com']

  spec.summary               = 'SAML IdP metadata.xml parser'
  spec.description           = 'SAML IdP metadata.xml parser'
  spec.homepage              = 'https://github.com/tknzk/saml_idp_metadata'
  spec.license               = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
end
