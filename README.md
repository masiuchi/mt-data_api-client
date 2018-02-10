# MT::DataAPI::Client

Movable Type Data API client for Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mt-data_api-client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mt-data_api-client

## Usage samples

```ruby
require 'mt/data_api/client'

# Set URL to your mt-data-api.cgi script.
client = MT::DataAPI::Client.new(
  base_url: 'http://localhost/mt/mt-data-api.cgi'
)

# Set endpoint ID and its arguments.
#
# * You can see the list of endpoints by "client.call(:list_endpoints)"
# * There is documentation of arguments at https://www.movabletype.jp/developers/data-api/.
res = client.call(:list_endpoints)
```

### With block

```ruby
require 'mt/data_api/client'

client = MT::DataAPI::Client.new(
  base_url: 'http://localhost/mt/mt-data-api.cgi'
)

client.call(:list_entries, site_id: 1) do |res|
  # ...
end
```

### Use authentication

```ruby
require 'mt/data_api/client'

client = MT::DataAPI::Client.new(
  base_url: 'http://loalhost/mt/mt-data-api.cgi'
)

res_auth = client.call(:authenticate, username: 'user', password: 'pass')

if res_auth && !res_auth.key?("error")
  res_list_plugins = client.call(:list_plugins)
end
```

### Use upload_asset endpoint

```ruby
require 'mt/data_api/client'

client = MT::DataAPI::Client.new(
  base_url: 'http://mt.test:5000/mt-data-api.cgi'
)

res_auth = client.call(:authenticate, username: 'user', password: 'pass')

if res_auth && !res_auth.key?("error")
  jpeg_file = File.open('sample.jpg', 'rb')
  res = client.call(:upload_asset, site_id: 1, file: jpeg_file)
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/masiuchi/mt-data_api-client.
