require "cerberus"

module Cerberus
  class Basic
    def initialize(app)
      @app = app
    end

    def call(env)
      if Cerberus.config.basic.enabled.call(env)
        auth = Rack::Auth::Basic.new(@app) do |username, password|
          username_digest = Cerberus.config.basic.username_digest
          password_digest = Cerberus.config.basic.password_digest

          eql?(username, username_digest) & eql?(password, password_digest)
        end

        auth.call(env)
      else
        @app.call(env)
      end
    end

    private

    def eql?(value, comparable)
      Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(value), comparable)
    end
  end
end

