# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  module Core
    class ModelBase < Attributes
      extend Resource
      include Resource

      include Nesting

      module Listable
        def all
          communication.get.map do |attributes|
            new(attributes, :stale => false)
          end
        end
      end

      module Creatable
        def create(attributes = nil)
          new(communication.post(attributes), :stale => false)
        end
      end

      module TopLevel
        def communication
          super || Scalapi.scalarium.communication[@toplevel]
        end
      end

      FEATURES = {:listable => Listable, :creatable => Creatable, :toplevel => TopLevel}

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
          extend FEATURES[id]
          instance_variable_set("@#{id}", args) if args
        end
      end

      def self.instance_communication_base=(communication)
        @instance_communication_base = communication
      end

      def self.instance_communication_base
        @instance_communication_base || communication
      end

      # Builds a new instance - bound to the provided communication (resource)
      def self.new(attributes = nil, options = {})
        attributes = {'id' => attributes} if String === attributes
        communication =
            if options.include?(:communication)
              options[:communication]
            else
              id = attributes && (attributes['id'] || attributes[:id])
              if id && instance_communication_base
                options = options.merge(:communication => instance_communication_base[id])
                options = options.merge(:stale => true) unless options.include?(:stale)
              else
                raise "Cannot determine url for the instance (class has no communication)"
              end
            end
        super(attributes, options)
      end

      def initialize(attributes, options = {})
        super(attributes)
        self.communication = options[:communication]
        @stale =
            if options.include?(:stale)
              options[:stale]
            else
              communication.nil?
            end
      end

      def communication
        super || begin
          id or raise "Id or resource required to load attributes"
          nesting_communication = self.class.instance_communication_base or
              raise "Cannot access resource (not available for instance nor class)"
          self.communication = nesting_communication[id]
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

