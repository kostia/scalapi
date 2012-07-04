# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  #
  # The configuration holds a server url, credentials, i/o headers, ...
  #
  # You can set up an initial (base) configuration using
  #
  #   Scalapi.configure do |config|
  #     config.token = "scalarium token"
  #     ...
  #   end
  #
  # This configuration will be available as
  #
  #   Scalapi.configuration
  #
  # and will be used for the default scalapi "connection"
  #
  #   Scalapi.scalarium   # (renewed each time you run Scalapi.configure)
  #
  #
  # Configurations can be stacked:
  #
  #   user_specific_configuration = Configuration.new(common_configuration)
  #   user_specific_configuration.token = "different scalarium token"
  #
  #
  # With a configuration you can set up a "handle" to the server
  #
  #   handle = Scalapi.bind(configuration)
  #
  class Configuration

    def self.default_configuration
      @default_configuration ||= begin
        new.configure do |config|
          config.url = "https://manage.scalarium.com/api"
          config.resource_headers = {
            'Accept' => 'application/vnd.scalarium-v1+json',
            'Content-Type' => 'application/json',
          }
        end.freeze
      end
    end

    def self.configuration
      @configuration ||= new(default_configuration)
    end

    # New configuration with fallback to base
    def initialize(base = nil)
      @base = base
    end

    # Syntactic sugar:
    #   configuration.configure do |config|
    #     config.token = token
    #   end
    #
    # Returns the configuration
    def configure
      yield self if block_given?
      self
    end

    # The scalarium token (required to access the api)
    def token=(token)
      @token = token
    end

    # returns the stored token (fallback to base configuration)
    # when final is true, complains about a missing token
    def token(final = true)
      token = @token || (@base && @base.token(false)) and return token
      raise "Scalarium token has not been configured" if final
    end

    # The scalarium api url (default: https://manage.scalarium.com)
    def url=(url)
      @url = url
    end

    # returns the stored url (fallback to base configuration)
    # when final is true, complains about a missing url
    def url(final = true)
      url = @url || (@base && @base.url(false)) and return url.sub(%r(/+$), "")
      raise "Missing scalarium base url" if final
    end

    # Additional HTTP Headers to send.
    # The following headers need not to be configured explicitely:
    # - X-Scalarium-Token: <the configured token>
    # The following  header need not to be configured when using the default configuration
    # (as a base)
    # - Accept:            application/vnd.scalarium-v1+json
    # - Content-Type:      application/json
    #
    # Will be provided as a second parameter to the (restclient) resource
    # representing '/' (to instantiate a Scalarium)
    def resource_headers=(resource_headers)
      @resource_headers = resource_headers
    end

    # Returns all headers set to the configuration stack. Appends a header for the
    # configured token unless it has been explicitely set.
    def resource_headers(final = true)
      headers = {}
      headers = headers.merge(@resource_headers || {})
      if (base_headers = @base && @base.resource_headers(false))
        base_headers.each do |(key, value)|
          headers.include?(key) || headers[key] = value
        end
      end
      if final
        headers.include?('X-Scalarium-token') or headers = headers.merge('X-Scalarium-Token' => token)
      end
      headers
    end

    # In case you don't want to I/O using the default RestClient::Resource.
    # Most probably only changed for test cases.
    # The resource must provide
    # - all the used request methods (#get, #post, #delete, ...)
    # - return sub-resource instances via #[<path>]
    # - #url to access the complete resource url
    def resource=(resource)
      @resource = resource
    end

    # The configured resource. Defaults to a RestClient::Resource created with the
    # configured url and headers.
    # If trace is active, returns the resource wrapped into a logging one.
    def resource(final = true)
      resource = @resource || (@base && @base.resource(false)) and return resource
      if final
        require 'rest_client'
        resource = RestClient::Resource.new(url, :headers => resource_headers(final))
        unless (traced_calls = self.trace(final)).empty?
          resource = Logging::TracingResource.new(resource, traced_calls)
        end
        resource
      end
    end

    # By default, the library talks json to scalarium. Allows you to change the
    # Marshaller/Unmarshaller combination (don't forget to change the Accept header)
    def coder(final = true)
      coder = @coder || (@base && @base.coder(false)) and return coder
      if final
        require 'multi_json'
        json_decoder, json_encoder =
            begin
              dump_method = begin MultiJson.method(:dump); rescue NameError; nil; end
              if dump_method && dump_method.owner == MultiJson
                [MultiJson.method(:load), dump_method]
              else
                [MultiJson.method(:decode), MultiJson.method(:encode)]
              end
            end
        decoder_spec = {"application/json" => json_decoder, nil => json_decoder}
        Core::Coder.new(decoder_spec, json_encoder)
      end
    end

    # :nodoc:
    def communication
      Core::Communication.new(resource(true), coder(true))
    end

    # Set a list of method calls for the resource instances to be traced.
    def trace=(methods)
      @trace = methods
    end

    def trace(final = true)
      trace = @trace || []
      trace += @base.trace(false) if @base
      trace
    end
  end
end
