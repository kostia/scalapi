# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  module Core
    module Nesting
      module Singleton
        def instance
          @instance ||= new(nil, :communication => communication, :stale => true)
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
        proxy = Class.new(proxied_class) do
          include Singleton unless respond_to?(:instance_communication_base)

          def self.new(attributes = nil, options = {})
            if respond_to?(:instance_communication_base)
              options = options.merge(:instance_communication_base => instance_communication_base)
            end
            superclass.new(attributes, options)
          end
        end

        proxy.communication = communication[path]

        if (instance_base_path = options[:instance_base_path])
          proxy.respond_to?(:instance_communication_base=) or
              raise "Option :instance_base_path not supported for #{proxied_class}"\
                  " (missing singleton method instance_communication_base)"
          proxy.instance_communication_base = communication[instance_base_path]
        end

        proxy
      end
    end
  end
end
