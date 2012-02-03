# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  module Core
    # Base class for resources which do not have an id (like Scalarium)
    # An instance is bound to an access url either explicitely provided or
    # implicitely build by the nesting resource.
    class Base < Attributes
      extend Resource
      include Resource

      include Nesting

      def initialize(attributes = nil, options = {})
        super(attributes)
        self.communication = options[:communication]
        @stale =
            if options.include?(:stale)
              options[:stale]
            else
              communication.nil?
            end
      end

      def attributes
        return super unless @stale
        communication or raise "Missing communication to fetch from"
        attributes = communication.get
        @stale = false
        @attributes = attributes
      end

      # discards an fetched data (reloads and caches on next access)
      def reload(fetch = false)
        @stale = true
        attributes if fetch
      end

    end
  end
end
