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

## Usage

    client = MT::DataAPI::Client.new(
      base_url: 'http://localhost/mt/mt-data-api.cgi',
      client_id: 'mt-ruby'
    )
    json = client.call(:list_entries, site_id: 1)

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mt-data_api.

