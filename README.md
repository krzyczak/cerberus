![](https://github.com/krzyczak/cerberus/workflows/Run%20RSpec%20Tests/badge.svg)
![](https://github.com/krzyczak/cerberus/workflows/Run%20tests%20and%20build%20the%20Ruby%20Gem/badge.svg)

# Cerberus

This gem provides various authentication middlewares.

At the moment there are two:
* `Cerberus::Jwt`
* `Cerberus::Basic`

## Installation

Add this line to your application's Gemfile:

```ruby
gem "cerber", require: "cerberus"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cerber

## Usage

Configure Cerberus with required information:

```ruby
require "cerberus"

Cerberus.configure do |config|
  config.jwt = {
    rsa_public: ENV["JWT_RSA_PUBLIC"],
    algorithm: "RS256",
    issuer: "org.website.project",
    enabled: ->(env) { Rails.env.production? }
  }.freeze

  config.basic = {
    username_digest: ::Digest::SHA256.hexdigest("test"),
    password_digest: ::Digest::SHA256.hexdigest("test"),
    enabled: ->(env) { env["PATH_INFO"].start_with?("/protected") }
  }.freeze
end

require "cerberus/jwt"
require "cerberus/basic"
```

And then just inject a middleware:

```ruby
config.middleware.use Cerberus::Jwt
config.middleware.use Cerberus::Basic
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/krzyczak/cerberus.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
