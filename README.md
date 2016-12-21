# Rack::RequestLogger

Rack middleware that will log request matching particular urls to logger mentioned by you & saves the request info to the database.
You will need to pass the database_configuration options to create connection to the db.
This gem internally uses Sequel to interact with the database.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-request_logger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-request_logger

## Usage

Intialize the middleware in your applciation.rb

```ruby
config.middleware.use Rack::RequestLogger, options
```

options have to be passed explicitly to the gem. Below are the options that can be provided
```
:logging_options, :table_name, :database_config, :url_regex, :request_logger
```

database_config & table_name are mandatory, without these the gem won't work.
logging_options will be an array containing the values you need to log.

Assuming you are using postgres as database and your database_name is test, the database_config will look like

```
database_config = {
  adapter: 'postgres',
  user: 'user',
  password: 'my_password',
  host: '127.0.0.1',
  database: 'test',
  search_path: 'my_schema'
}
```
search_path can be a string or a PROC in case you are using Tenants in your database.
Following parameters are mandatory for database_config
```
[:adapter, :host, :database, :user, :password]
```

Logging Options:- This gem can log following things into your database

```
[:time, :method, :format, :endpoint, :status, :ip, :query_params, :request_body, :response]
```

You can cutoff the options you provide to just store what you need. In case this parameter is not provided all the options will be logged by default.

NOTE:- Table column names should match the logging_options keys mentioned above.
```
time -> datetime
method -> string
format -> string
endpoint -> string
status -> integer
ip -> string
query_params -> string
request_body -> text
response -> text
```

Eg -
```
request_logger_options = {
      database_config: database_config,
      table_name: :api_requests,
      url_regex: %r{api/v1/},
      logging_options: [:time, :method, :ip, :response, :status, :query_params, :request_body, :endpoint],
      request_logger: Logger.new(Rails.root.join('log', 'api_requests.log'), 10, 1000000)
    }
```
Here, url_regex is the regex for the urls you want to log the requests. By default it will be /api/.
request_logger, an optional parameter can be passed to log out the request to particular file. In case its not provided default app's logger will be used to log the requests.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rack-request_logger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
