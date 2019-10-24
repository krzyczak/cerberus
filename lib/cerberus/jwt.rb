require "cerberus"

module Cerberus
  class Jwt
    JWT_OPTIONS = {
      algorithm: Cerberus.config.jwt.algorithm || ENV["JWT_ALGORITHM"],
      iss: Cerberus.config.jwt.issuer || ENV["JWT_ISSUER"],
      verify_iss: true,
      verify_iat: true
    }.freeze

    JWT_ERRORS = {
      JWT::ExpiredSignature => {
        status: 403, body: "The token has expired."
      },
      JWT::InvalidIssuerError => {
        status: 403, body: "The token does not have a valid issuer."
      },
      JWT::InvalidIatError => {
        status: 403, body: "The token does not have a valid 'issued at' time."
      },
      JWT::DecodeError => {
        status: 401, body: "A valid token must be passed."
      },
      KeyError => {
        status: 401, body: "HTTP_AUTHORIZATION header must be present."
      }
    }.freeze

    class EmptyJWT < StandardError
      DEFAULT_ERROR_MESSAGE = "Cerberus CONFIG: config.jwt.rsa_public option needs to be set."

      def initialize(error_message = DEFAULT_ERROR_MESSAGE)
        super(error_message)
      end
    end

    raise EmptyJWT("Cerberus CONFIG: config.jwt is empty.") if Cerberus.config.jwt.empty?
    raise EmptyJWT if Cerberus.config.jwt.rsa_public.to_s.strip.empty?

    JWT_RSA_PUBLIC = OpenSSL::PKey::RSA.new(Base64.decode64(Cerberus.config.jwt.rsa_public))

    def initialize(app)
      @app = app
    end

    def call(env)
      if Cerberus.config.jwt.enabled.call(env)
        auth_token = env.fetch("HTTP_AUTHORIZATION").gsub(/bearer /i, "")
        _payload, _header = JWT.decode(auth_token, JWT_RSA_PUBLIC, true, JWT_OPTIONS)
      end

      @app.call(env)
    rescue StandardError => error
      if JWT_ERRORS.keys.include?(error.class)
        self.class.respond_with(*JWT_ERRORS.fetch(error.class).values)
      else
        raise error
      end
    end

    def self.respond_with(status_code, message)
      [status_code, { "Content-Type" => "text/plain" }, [message]]
    end
  end
end
