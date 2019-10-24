# frozen_string_literal: true

# Dummy RSA private and publci keys.
JWT_ISSUER="com.issuer.interesting"
JWT_ALGORITHM="RS256"
JWT_RSA_PUBLIC="MFswDQYJKoZIhvcNAQEBBQADSgAwRwJAY+SUz11CfhGyHSntWY9M5QSdQ+IdekmrJ08voEdwnXwpzlvoZW3wyukVh1JyVb4H/rCDS3ivo2rGjD5Mc1MsVwIDAQAB"
JWT_RSA_PRIVATE="MIIBOQIBAAJAY+SUz11CfhGyHSntWY9M5QSdQ+IdekmrJ08voEdwnXwpzlvoZW3wyukVh1JyVb4H/rCDS3ivo2rGjD5Mc1MsVwIDAQABAkBevVAVS1Hg10+iMT2Wjz5ShonQ9AcZD/1vjr6QuLCp6wUhLSTDV1kiBkDIzxeXdeGw5w40AIeRIqMVtz/ddJ+hAiEAo6ja/JyNuyC/RKMFPQwgBDCaa6pYJjGGrQda/WTK5eMCIQCcQTRjX1J1pY2O/zjC7SOJkWP4xrYHpoj1+1TL3bMJ/QIhAJfrkvyTxu1CRMrOGXrF2qKJC4+OHS23I7FS9p/qBH7JAiBdO4rGwFmzWNTePergZB6QNvAvwGFcr0GJhC1UdzQdAQIgfeqwAnsADmCUnPVMYZ9YLWz5klDS+tilLRP9t1z1TNE="

Cerberus.configure do |config|
  config.jwt = {
    rsa_public: JWT_RSA_PUBLIC,
    algorithm: JWT_ALGORITHM,
    issuer: JWT_ISSUER,
    enabled: ->(env) { env["PATH_INFO"].start_with?("/protected") }
  }.freeze
end

require "cerberus/jwt"

RSpec.describe Cerberus::Jwt, :with_auth_token do
  include Rack::Test::Methods

  let(:app) do
    Rack::Builder.new do |builder|
      builder.use(Cerberus::Jwt)
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
    before do
      get "/protected", nil, headers
    end

    subject { last_response }

    its(:body) { is_expected.to eq("Protected stuff.") }

    context "when signature is expired" do
      let(:exp) { Time.now.to_i - 100 }

      its(:status) { is_expected.to eq(403) }
      its(:body) { is_expected.to eq("The token has expired.") }
    end

    context "when issuer is invalid" do
      let(:iss) { JWT_ISSUER + "_some_fake_stuff" }

      its(:status) { is_expected.to eq(403) }
      its(:body) { is_expected.to eq("The token does not have a valid issuer.") }
    end

    context "when issuer is not present in the headers" do
      let(:auth_payload) do
        { exp: exp, iat: iat }
      end

      its(:status) { is_expected.to eq(403) }
      its(:body) { is_expected.to eq("The token does not have a valid issuer.") }
    end

    context "when issued at is invalid" do
      let(:iat) { "sdfsdfsdfsdf" }

      its(:status) { is_expected.to eq(403) }
      its(:body) { is_expected.to eq("The token does not have a valid 'issued at' time.") }
    end

    context "when token is invalid" do
      let(:headers) do
        {
          "CONTENT_TYPE" => "application/json",
          "HTTP_AUTHORIZATION" => "Bearer NOT_VALID_TOKEN"
        }
      end

      its(:status) { is_expected.to eq(401) }
      its(:body) { is_expected.to eq("A valid token must be passed.") }
    end

    context "when token is not present" do
      let(:headers) do
        {
          "CONTENT_TYPE" => "application/json"
        }
      end

      its(:status) { is_expected.to eq(401) }
      its(:body) { is_expected.to eq("HTTP_AUTHORIZATION header must be present.") }
    end
  end
end
