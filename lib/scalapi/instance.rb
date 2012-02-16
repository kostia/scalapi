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

    # Options (according to http://support.scalarium.com/kb/api/deleting-instances):
    #   delete_volumes: true
    #   delete_elastic_ip: true
    def delete(options = nil)
      communication.delete(options)
    end

  end
end
