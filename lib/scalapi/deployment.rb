# encoding: utf-8
#
# Copyright (c) Infopark AG
#
module Scalapi
  class Deployment < Core::Model
    def for_instance(id)
      instance_deployment = nested("instances", :class => InstanceDeployment).build(id)
      instance_deployment.reload(true)
      instance_deployment
    end
  end
end
