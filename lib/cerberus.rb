require "ostruct"
require "jwt"
# Bundler.require(:default, :development)
require "cerberus/version"

module Cerberus
  class Error < StandardError; end
  # Your code goes here...

  class << self
    attr_accessor :config
  end

  def self.configure
    self.config ||= Config.new
    yield(config)
    self.config.jwt = OpenStruct.new(self.config.jwt || {})
    self.config.jwt.skip_middleware_unless ||= -> { false }

    self.config.basic = OpenStruct.new(self.config.basic || {})
    self.config.basic.enabled ||= -> { true }
  end

  class Config
    attr_accessor(:jwt, :basic)
  end

  self.configure {}
end
