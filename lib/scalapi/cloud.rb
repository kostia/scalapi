# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  class Cloud < Core::Model

    features :listable, :creatable
    features :toplevel => "clouds"


    module Applications

      # Not available
      # def applications
      #   nested_applications.all
      # end

      def create_application(attributes)
        nested_applications(:instance_base_path => "/applications").create(attributes)
      end

      def delete_application(id)
        nested_applications.build(id).delete
      end

      def nested_applications(options = {})
        nested("applications", {:class => Application}.merge(options))
      end

      protected :nested_applications

    end

    module Deployments

      # Not available
      # def deployments
      #   nested_deployments.all
      # end

      # TODO: Verify existence - or use build(id) instead
      def find_deployment(id)
        nested_deployments.find(id)
      end

      def nested_deployments
        nested("deployments", :class => Deployment)
      end

      protected :nested_deployments

    end

    module Instances
      def instances
        nested_instances.all
      end

      def find_instance(id)
        nested_instances.find(id)
      end

      def create_instance(*attributes)
        nested_instances.create(*attributes)
      end

      def nested_instances
        nested("instances", :class => Instance)
      end

      protected :nested_instances

    end

    module Roles

      def roles
        nested_roles.all
      end

      def find_role(id)
        nested_roles.find(id)
      end

      def create_role(*attributes)
        nested_roles.create(*attributes)
      end

      def nested_roles
        nested("roles", :class => Role)
      end

      protected :nested_roles

    end

    include Applications
    include Deployments
    include Instances
    include Roles

    module DeploymentOperations

      def deploy(command, options = {})
        deployment_details = {:command => command}.merge(options)
        deployment_properties = communication["deploy"].post(deployment_details)
        nested_deployments.new(deployment_properties, nil, true)
      end

      def execute_recipes(recipes, options = {})
        deploy('execute_recipes', {:recipes => recipes}.merge(options))
      end

      def install_dependencies(options = {})
        deploy('install_dependencies', options)
      end

      def update_custom_cookbooks(options = {})
        deploy('update_custom_cookbooks', options)
      end

      def update_dependencies(options = {})
        deploy('update_dependencies', options)
      end

    end

    include DeploymentOperations

    def volumes
      instance_ids = instances.inject([]) {|memo, instance| memo << instance.id}
      nested("/volumes", :class => Volume).all.select do |v|
        instance_ids.include?(v['instance_id'])
      end
    end

  end
end
