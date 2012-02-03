# encoding: utf-8
#
# Copyright (c) Infopark AG
#
require File.expand_path("../../spec_helper.rb", __FILE__)

module Scalapi
  describe Deployment, "find_instance(<id>)" do
    before do
      intercept_scalapi_calls
    end

    let(:deployment) {
      instantiate_model("de_pl_oy", :class => Deployment,
          :base => "applications/support_app/deployments")
    }

    it "sends a GET request to '<deployment_nester>/deployments/<de_id>/instances/<id>'" do
      intercepted_calls["applications/support_app/deployments/de_pl_oy/instances/inst"].
          should_receive(:get).
          and_return('{"id":"depl_inst"}')
      deployment.for_instance("inst").should be
    end

    it "returns an instance deployment based on the properties from the response" do
      intercepted_calls["applications/support_app/deployments/de_pl_oy/instances/inst"].
          should_receive(:get).
          and_return(json_response("id" => "depl_inst", "log_url" => "5 minute log access"))
      instance_deployment = deployment.for_instance("inst")
      instance_deployment.should be_instance_of(InstanceDeployment)
      instance_deployment.id.should == "depl_inst"
      instance_deployment['log_url'].should == "5 minute log access"
    end
  end

end

