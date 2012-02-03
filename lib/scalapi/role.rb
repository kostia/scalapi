# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  class Role < Core::Model

    features :listable, :creatable

    module Instances

      def instances
        nested_instances.all
      end

      def nested_instances
        nested("instances", :class => Instance, :instance_base_path => "../../instances")
      end

      protected :nested_instances

    end

    include Instances

  end
end

