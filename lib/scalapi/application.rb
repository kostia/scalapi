# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  class Application < Core::Model

    features :listable, :creatable
    features :top_level => "applications"

    module Deployments

      def deployments
        nested_deployments.all
      end

      def find_deployment(id)
        nested_deployments.find(id)
      end

      def nested_deployments
        nested("deployments", :class => Deployment)
      end

      protected :nested_deployments

    end

    include Deployments

    module DeploymentOperations

      def deploy(command, options = {})
        communication["deploy"].post({:command => command}.merge(options))
      end

    end

    include DeploymentOperations

    def self.find_by_name(name)
      all.detect {|app| app['name'] == name}
    end

    # Only available when belonging to a cloud (resource knows if)
    def delete
      communication.delete
    end

    # returns a new application with the same id bound to a top level resource path
    # there is no use case yet (no application instance is created with a non-top-level path)
    #
    # def global
    #   self.class.new({'id' => id}, communication["/applications/#{id}"], false)
    # end

  end
end
