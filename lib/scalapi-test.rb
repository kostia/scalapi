# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Test
  module Scalapi
    # A Resource which complains on every operation performed on it.
    # There will be only one instance of a resource for a given path (unlike
    # RestClient::Resource).
    # This simplifies the access to the object the request operation has been
    # sent to to Test::Scalapi.resource[<path>].
    #
    # Use Test::Scalapi.intercept_scalapi_calls to activate the test Resource.

    class Resource
      def self.reset
        @resources = nil
      end

      def self.[](path, base)
        @resources ||= {}
        @resources[base] ||= {}
        @resources[base][path] ||= new(path, base)
      end

      attr_reader :path, :base

      def initialize(path, base)
        @path = path
        @base = base
      end

      def url
        base + path
      end

      def [](sub)
        self.class[path + "/#{sub}", base]
      end

      def get(*args)
        raise "Unexpected call: GET #{path}#{" #{args.inspect}" unless args.empty?}"
      end

      def post(*args)
        raise "Unexpected call: POST #{path}#{"(#{args.first.inspect})" if args.first}"
      end

      def put(*args)
        raise "Unexpected call: PUT #{path}(#{body.inspect})"
      end

      def delete(*args)
        raise "Unexpected call: DELETE #{path}#{" #{args.inspect}" unless args.empty?}"
      end
    end

    # Replaces the default RestClient::Resource with one that simplifies
    # stubbing the resource requests:
    #
    # Test::Scalapi.resource[<path>] is the object the # requests are sent to.
    def self.intercept_scalapi_calls(resource = self.resource)
      ::Scalapi.configure do |config|
        config.resource = resource
      end
    end

    # The top of the test resource stack
    def self.resource(base = "http://scalarium.example.com")
      Resource["", base]
    end

    # Reset the scalapi library to it's state before configuration
    def self.unconfigure
      ::Scalapi::Configuration.instance_variable_set("@configuration", nil)
      ::Scalapi.instance_variable_set("@scalarium", nil)
      Resource.reset
    end

    # attributes may be an id
    def self.instantiate_model(attributes, options = {})
      model_class = options[:class] || ::Scalapi::Core::Model
      scalarium = options[:root] || ::Scalapi.scalarium
      parent_path = options[:base] || "#{model_class.name.underscore} + s"
      id =
          case attributes
          when String
            attributes
          else
            attributes['id']
          end
      path = parent_path
      path += "/#{id}" if id
      model_options = {:communication => scalarium.communication[path]}
      model_options.merge!(:stale => options[:stale]) if options.include?(:stale)
      model_class.new(attributes, model_options)
    end

    module ResponseHelper
      attr_accessor :headers
    end

    def self.json_response(obj, headers = {})
      response =
          case obj
          when String
            obj
          else
            MultiJson.encode(obj)
          end
      response.extend(ResponseHelper)
      response.headers = headers.merge(:content_type => "application/json")
      response
    end
  end
end
