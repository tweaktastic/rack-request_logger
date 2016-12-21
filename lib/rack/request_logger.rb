require "rack/request_logger/version"
require "rack/request_logger/constants"

module Rack
  class RequestLogger

    def initialize(app, options={})
      @app = app
      options = standardize_option_keys(options)
      options.each do |key, value|
        set_instance_variable(key, value)
      end
      if missing_required_db_options? || @table_name.nil?
        return false
      end
    end

    def call(env)
      @env = env
      if env['PATH_INFO'] =~ @url_regex
        log_data_and_connect_db
        set_loggers(@request_logger) if @request_logger.present?
        begin
          @status, @headers, @response = @app.call(env)
          set_data_for_db(@status, @response.body)
          @db[@table_name].insert(@db_data)
        rescue StandardError => e
          trace = e.backtrace.select{ |l| l.start_with?(Rails.root.to_s) }
          msg = "#{e.class}\n#{e.message}\n#{trace.join("\n")}\n"
          @request_logger.error(msg) if @request_logger.present?
          set_data_for_db(500, "#{e.class}, #{e.message}, #{trace.join("")}")
          @db[@table_name].insert(@db_data)
          raise e
        end
      else
        @status, @headers, @response = @app.call(env)
      end
      [@status, @headers, @response]
    end

    private

    def set_loggers(logger)
      Rails.instance_variable_set(:@logger, logger)
      ActionController::Base.logger = logger
      ActiveRecord::Base.logger = logger
      ActionView::Base.logger = logger
    end

    def options_to_log(options)
      options.select{ |option| DEFAULT_LOGGING_OPTIONS.include?(option) }
    end

    def missing_required_db_options?
      valid_options = @database_config.select{ |option, value|
                      REQUIRED_DATABASE_OPTIONS.include?(option) }
      valid_options.length <  REQUIRED_DATABASE_OPTIONS.length
    end

    def gather_logging_data
      @log = {
          time: Time.now,
          method: @env['REQUEST_METHOD'],
          format: @env['api.format'],
          endpoint: @env['PATH_INFO'],
          ip: @env['REMOTE_ADDR'],
          query_params: @env['QUERY_STRING'],
          requst_body: @env['api.request.body']
      }
    end

    def set_data_for_db(status = 500, response)
      @logging_options.each{ |option| @db_data[option] = @log[option] }
      @db_data[:status] = status
      @db_data[:response] = response
    end

    def resolve_search_path
      @database_config[:search_path] = (@database_config[:search_path].class == Proc) ?
                                        @database_config[:search_path].call(
                                        Rack::Request.new(@env)) :
                                            @database_config[:search_path]
    end

    def set_instance_variable(key, value)
      case key
      when :url_regex
        value = value.nil? ? DEFAULT_API_PATH : value
      when :logging_options
        value = value.nil? ? DEFAULT_LOGGING_OPTIONS : options_to_log(value)
      when :table_name
        value = value.to_sym
      end
      instance_variable_set("@#{key}", value)
    end

    def standardize_option_keys(options)
      OPTIONS.each{|x| options[x] = nil if !options.has_key?(x)}
      options
    end

    def log_data_and_connect_db
      gather_logging_data
      resolve_search_path if @database_config[:search_path].present?
      @db = Sequel.connect(@database_config)
      @db_data = Hash.new(0)
    end

  end
end
