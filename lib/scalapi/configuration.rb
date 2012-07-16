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
    attr_accessor :token

    # returns the stored token (fallback to base configuration)
    # when final is true, complains about a missing token
    def token(final = true)
      property(:token, final) do
        raise "Scalarium token has not been configured"
      end
    end

    # The scalarium api url (default: https://manage.scalarium.com)
    attr_writer :url

    # returns the stored url (fallback to base configuration)
    # when final is true, complains about a missing url
    def url(final = true)
      url = property(:url, final) do
        raise "Missing scalarium base url"
      end
      url = url.sub(%r(/+$), "") if url
      url
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
    attr_writer :resource_headers

    # Returns all headers set to the configuration stack. Appends a header for the
    # configured token unless it has been explicitely set.
    def resource_headers(final = true)
      headers = {}.merge(base_property(:resource_headers)).merge(@resource_headers || {})
      if final && !headers.include?('X-Scalarium-token')
        headers = headers.merge('X-Scalarium-Token' => token)
      end
      headers
    end

    # In case you want a different top level rest client resource (e.g. provide
    # some more options), you can provide your own (rest client) resource_builder.
    #
    # It must respond_to?(:call) (with arguments url and :headers => resource_headers) and
    # return a resource which provides
    # - all the used request methods (#get, #post, #delete, ...)
    # - return sub-resource instances via #[<path>]
    # - #url to access the complete resource url
    attr_writer :resource_builder

    def resource_builder(final = true)
      property(:resource_builder, final) do
        require 'rest_client'
        RestClient::Resource.method(:new)
      end
    end

    # If you want to replace the resource completely.
    # Especially for tests where token and url don't matter.
    # In other cases, you should better use resource_builder instead.
    attr_writer :resource

    # The (top level) resources as returned by the configured resource_builder.
    # Defaults to a RestClient::Resource created with the configured url and headers.
    # If trace is active, returns the resource wrapped into a logging one.
    def resource(final = true)
      property(:resource, final) do
        resource = resource_builder.call(url, :headers => resource_headers(final))
        traced_calls = trace(true) || []
        resource = Logging::TracingResource.new(resource, traced_calls) unless traced_calls.empty?
        resource
      end
    end

    # By default, the library talks json to scalarium. Allows you to change the
    # Marshaller/Unmarshaller combination (don't forget to change the Accept header)
    def coder(final = true)
      property(:coder, final) do
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

    # Set a list of method names for the resource instances to be traced.
    #
    # Example:
    #
    #   configuration.trace([:get])
    #
    attr_writer :trace

    def trace(final = true)
      property(:trace, final)
    end

    # :nodoc:
    def property(name, final, &block)
      property = instance_variable_get("@#{name}")
      property ||= base_property(name)
      if final && block_given?
        property ||= yield property
      end
      property
    end

    # :nodoc:
    def base_property(name)
      @base.property(name, false) if @base
    end
  end
end
