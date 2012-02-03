# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  class Instance < Core::Model

    features :listable, :creatable

    module InstanceOperations

      def start
        communication["start"].post
      end

      def reboot
        communication["reboot"].post
      end

      def stop
        communication["stop"].post
      end

    end

    include InstanceOperations

    def volumes
      nested("/volumes", :class => Volume).all.select do |v|
        v['instance_id'] == id
      end
    end

  end
end
