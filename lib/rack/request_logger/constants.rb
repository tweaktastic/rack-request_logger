module Rack

  class RequestLogger

    DEFAULT_API_PATH = %r{api/}
    DEFAULT_LOGGING_OPTIONS = [:time, :method, :format, :endpoint, :status, :ip,
                              :query_params, :request_body, :response]
    REQUIRED_DATABASE_OPTIONS = [:adapter, :host, :database, :user, :password]
    OPTIONS = [:logging_options, :table_name, :database_config,
             :url_regex, :request_logger]
  end

end
