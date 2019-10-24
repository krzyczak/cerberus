# Cerberus

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/cerberus`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem "cerberus"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cerberus

## Usage

Configure Cerberus with required information:

```ruby
Cerberus.configure do |config|
  config.jwt_rsa_public = ENV["JWT_RSA_PUBLIC"]
  config.jwt_algorithm = "RS256"
  config.jwt_issuer = "org.website.project"
  config.jwt_skip_middleware_unless = -> { |env| Rails.env.production? }
end

require "cerberus/jwt"
```

And then just inject a middleware:

```ruby
config.middleware.use Cerberus::Jwt
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cerberus.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
