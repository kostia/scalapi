# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  module Core
    module Nesting
      module Singleton
        def instance
          @instance ||= proxied_class.new(nil, :communication => @communication, :stale => true)
        end
      end

      class Proxy

        attr_reader :proxied_class

        def initialize(communication, proxied_class, instance_communication_base)
          @communication = communication
          @proxied_class = proxied_class
          @instance_communication_base = instance_communication_base
          base =
              if proxied_class < ModelBase
                ModelBase
              elsif proxied_class < Base
                Base
              else
                raise "Unsupported class for nesting: #{proxied_class}"
              end

          meta = class << self; self; end
          methods = proxied_class.singleton_methods - base.singleton_methods
          extensions = (class << proxied_class; self; end).included_modules
          extensions -= (class << base; self; end).included_modules
          extensions.each do |m|
            methods.concat(m.instance_methods)
          end
          methods.uniq.each do |method|
            meta.instance_eval do
              define_method(method.to_sym) do |*args|
                call_nested_class_method(method, *args)
              end
            end
          end

          meta.__send__(:include, Singleton) if Base == base
        end

        def call_nested_class_method(method, *args)
          proxied_class.communication = @communication
          if @instance_communication_base
            proxied_class.instance_communication_base = @instance_communication_base
          end
          proxied_class.__send__(method.to_sym, *args)
        ensure
          proxied_class.communication = nil
          proxied_class.instance_communication_base = nil if @instance_communication_base
        end
      end

      # Creates a proxy to the sub-resource of this resource
      # with the given path.
      #
      #   nested("clouds", :class => Cloud)
      #
      # There are two kind of sub-resources currently supported:
      # 1) Models
      #    The path defines the name of the index.
      #    Instances will be auto-located at <given sub_path>/<instance-id>
      #    See Scalapi::Core::Model
      # 2) Singletons
      #    The path defines the name of the resource itself.
      #    The instance can be retrieved by calling ".instance":
      #    nested("example", :class => Example).instance
      #
      # Available options:
      #   :class => SomeClass
      #     the class to build instances of (default: Model)
      #   :instance_base_path => "other path"
      #       use "other path"/<id> as the location for model instances when
      #       created from e.g. an index request (Model.all) (default: path/<id>)
      #       Note: The standard .find(<id>) will still seek at path/<id>
      #       Note: Use instance.reload to fetch the instance's
      #             attributes from the relocated location
      def nested(path, options = {})
        proxied_class = options[:class] || Model
        instance_communication_base =
          if (instance_base_path = options[:instance_base_path])
            proxied_class.respond_to?(:instance_communication_base) or
                raise "Option :instance_base_path not supported for #{proxied_class}"\
                    " (missing singleton method instance_communication_base)"
            communication[instance_base_path]
        end
        Proxy.new(communication[path], proxied_class, instance_communication_base)
      end
    end
  end
end
