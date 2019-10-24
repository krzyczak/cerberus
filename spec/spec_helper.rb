require "bundler/setup"
require "cerberus"

require "rack/test"
require "rspec/its"

require File.expand_path("support/with_auth_token.rb", __dir__)
require File.expand_path("support/test_application.rb", __dir__)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include_context(:with_auth_token, :with_auth_token)
end
