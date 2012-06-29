# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  module Core

    module InstantiatableResource

      def instance_communication_base=(communication)
        @instance_communication_base = communication
      end

      def instance_communication_base
        @instance_communication_base || communication
      end

    end


    class Model < Attributes

      extend Resource
      extend InstantiatableResource

      include Resource
      include Nesting


      def self.features(*features)
        feature_definitions = []
        features.each do |d|
          case d
          when Symbol
            feature_definitions << [d, nil]
          when Array
            feature_definitions << d
          when Hash
            d.each do |entry|
              feature_definitions << entry
            end
          end
        end

        feature_definitions.each do |id, args|
          extend Features.const_get("_#{id}".gsub(/_(.)/) {$1.upcase})
          instance_variable_set("@#{id}", args) if args
        end
      end

      def self.find(id)
        return nil if id.to_s == ""
        instance = build(id)
        begin
          instance.reload(true)
          instance
        rescue => e
          return nil if "404" == (e.http_code rescue nil).to_s
          raise e
        end
      end

      def self.build(id)
        new({'id' => id}, :communication => communication[id], :stale => true)
      end

      # Builds a new instance - bound to the provided communication (resource)
      def self.new(attributes = nil, options = {})
        attributes = {'id' => attributes} if String === attributes
        super(attributes, options)
      end

      def initialize(attributes, options = {})
        super(attributes)
        self.communication = options[:communication]
        @instance_communication_base = options[:instance_communication_base]

        @stale =
            if options.include?(:stale)
              options[:stale]
            else
              options[:communication].nil?
            end
      end

      def instance_communication_base
        @instance_communication_base || self.class.instance_communication_base
      end

      def communication
        super || begin
          id or raise "Instance is neither bound to an url nor has an id"
          instance_communication_base or
              raise "No instance url prefix provided to determine url from id"
          self.communication = instance_communication_base[id]
        end
      end

      def attributes
        return super unless @stale
        attributes = communication.get
        @stale = false
        @attributes = attributes
      end

      # discards any fetched data (reloads and caches on next access)
      def reload(fetch = false)
        @stale = true
        attributes if fetch
      end

      def id
        @attributes['id'] if @attributes
      end

    end
  end
end

