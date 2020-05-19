# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter %r{^/spec/}
  require 'simplecov'
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'saml_idp_metadata'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
