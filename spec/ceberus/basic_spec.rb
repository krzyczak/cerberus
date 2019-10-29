# frozen_string_literal: true

Cerberus.configure do |config|
  config.basic = {
    username_digest: ::Digest::SHA256.hexdigest("test"),
    password_digest: ::Digest::SHA256.hexdigest("test"),
    enabled: ->(env) { env["PATH_INFO"].start_with?("/protected") }
  }.freeze
end

require "cerberus/basic"

RSpec.describe Cerberus::Basic do
  include Rack::Test::Methods

  let(:app) do
    Rack::Builder.new do |builder|
      builder.use(Cerberus::Basic)
      builder.run(TestApplication.new)
    end
  end

  context "when accessing unprotected route" do
    it "returns the status 200" do
      get "/status"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")
    end
  end

  context "when accessing protected route" do
    let(:username) { "test" }
    let(:password) { "test" }

    before do
      basic_authorize(username, password)
      get "/protected"
    end

    subject { last_response }

    context "with valid username and password" do
      its(:status) { is_expected.to eq(200) }
      its(:body) { is_expected.to eq("Protected stuff.") }
    end

    context "with invalid username" do
      let(:username) { "invalid" }

      its(:status) { is_expected.to eq(401) }
      its(:body) { is_expected.to eq("") }
    end

    context "with invalid password" do
      let(:username) { "invalid" }

      its(:status) { is_expected.to eq(401) }
      its(:body) { is_expected.to eq("") }
    end
  end
end
