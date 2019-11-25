# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'saml_idp_metadata'

Dir['./spec/support/**/*.rb'].sort.each { |f| require f }
