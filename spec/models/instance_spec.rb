# encoding: utf-8
#
# Copyright (c) Infopark AG
#
require File.expand_path("../../spec_helper.rb", __FILE__)

module Scalapi
  describe Instance, "#reboot" do
    let(:instance) {
      instantiate_model({"id" => "id_of_instance"}, :class => Instance,
          :base => "clouds/id_of_cloud/instances")
    }

    before do
      intercept_scalapi_calls
    end

    it "sends a POST request to the /cloud/cloud_id/instance/instance_id/reboot" do
      intercepted_calls["clouds/id_of_cloud/instances/id_of_instance/reboot"].
          should_receive(:post)

      instance.reboot
    end
  end

  describe Instance, "#start" do
    let(:instance) {
      instantiate_model({"id" => "id_of_instance"}, :class => Instance,
          :base => "clouds/id_of_cloud/instances")
    }

    before do
      intercept_scalapi_calls
    end

    it "sends a POST request to the /cloud/cloud_id/instance/instance_id/start" do
      intercepted_calls["clouds/id_of_cloud/instances/id_of_instance/start"].
          should_receive(:post)

      instance.start
    end
  end

  describe Instance, "#stop" do
    let(:instance) {
      instantiate_model({"id" => "id_of_instance"}, :class => Instance,
          :base => "clouds/id_of_cloud/instances")
    }

    before do
      intercept_scalapi_calls
    end

    it "sends a POST request to the /cloud/cloud_id/instance/instance_id/stop" do
      intercepted_calls["clouds/id_of_cloud/instances/id_of_instance/stop"].
          should_receive(:post)

      instance.stop
    end
  end
end
