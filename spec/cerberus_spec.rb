# frozen_string_literal: true

RSpec.describe Cerberus, :with_auth_token do
  include Rack::Test::Methods

  it "has a version number" do
    expect(Cerberus::VERSION).not_to be(nil)
  end
end
