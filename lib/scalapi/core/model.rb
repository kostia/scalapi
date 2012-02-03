# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  module Core
    class Model < ModelBase

      def self.build(id)
        new({'id' => id}, :communication => communication[id], :stale => true)
      end

      def self.find(id)
        instance = build(id)
        begin
          instance.reload(true)
          instance
        rescue => e
          return nil if "404" == (e.http_code rescue nil).to_s
          raise e
        end
      end

    end
  end
end
