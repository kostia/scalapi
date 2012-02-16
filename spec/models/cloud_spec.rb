# encoding: utf-8
#
# Copyright (c) Infopark AG
#
require File.expand_path("../../spec_helper.rb", __FILE__)

module Scalapi
  describe Cloud, "#delete" do
    before do
      intercept_scalapi_calls
    end

    let(:cloud) {
      Cloud.new("cloud_under_test")
    }

    it "should send a DELETE request do '/clouds/<cloud_id>'" do
      intercepted_calls["clouds/cloud_under_test"].should_receive(:delete)
      cloud.delete
    end
  end
end


module Scalapi

  describe Cloud, "#create_application(attributes)" do
    before do
      intercept_scalapi_calls
    end

    let(:cloud) {
      Cloud.new("cloud_under_test")
    }

    it "sends a POST request to '/clouds/<cloud_id>/applications'" do
      intercepted_calls["clouds/cloud_under_test/applications"].
          should_receive(:post).with(%r#^\{("name":"new_app"|"mounted_at":"/"|,)+\}$#).
          and_return('{"id":"app_created","name":"new_app","mounted_at":"/"}')

      cloud.create_application({:name => "new_app", :mounted_at => "/"})
    end

    it "returns an application instance based on the returned properties" do
      intercepted_calls["clouds/cloud_under_test/applications"].stub(:post).
          and_return('{"id":"app_created","name":"returned_name","mounted_at":"/"}')

      application = cloud.create_application({:name => "new_app", :mounted_at => "/"})
      application.should be
      application.should be_instance_of(Application)
      application['name'].should == "returned_name"
    end

    it "returns an application instance bound to top-level /applications/<id>" do
      intercepted_calls["clouds/cloud_under_test/applications"].stub(:post).
          and_return('{"id":"app_created","name":"returned_name","mounted_at":"/"}')

      application = cloud.create_application({:name => "new_app", :mounted_at => "/"})
      application.should be
      intercepted_calls["applications/app_created"].should_receive(:get).
          and_return('{"id":"app_created","name":"returned_name","mounted_at":"/"}')
      application.reload(true)
    end

  end

  describe Cloud, "#delete_application(id)" do
    before do
      intercept_scalapi_calls
    end

    let(:cloud) {
      Cloud.new("cloud_under_test")
    }

    it "sends a DELETE request to '/clouds/<cloud_id>/applications/<id>'" do
      intercepted_calls["clouds/cloud_under_test/applications/apfel"].should_receive(:delete)
      cloud.delete_application("apfel")
    end
  end
end

module Scalapi
  describe Cloud, "find_deployment(<id>)" do
    before do
      intercept_scalapi_calls
    end

    let(:cloud) {
      Cloud.new("cloud_under_test")
    }

    it "sends a GET request to '/clouds/<cloud_id>/deployments/<id>'" do
      intercepted_calls["clouds/cloud_under_test/deployments/de_pl_oy"].
          should_receive(:get).
          and_return('{"id":"de_pl_oy"}')
      cloud.find_deployment("de_pl_oy").should be
    end

    it "returns a deployment instance based on the properties from the response" do
      intercepted_calls["clouds/cloud_under_test/deployments/de_pl_oy"].
          should_receive(:get).
          and_return('{"id":"de_pl_oy","prop":"erty"}')
      (deployment = cloud.find_deployment("de_pl_oy")).should be
      deployment['prop'].should == "erty"
    end
  end

end

module Scalapi
  describe Cloud, "#create_instance(attributes)" do
    before do
      intercept_scalapi_calls
    end

    let(:cloud) {
      Cloud.new("cloud_under_test")
    }

    it "sends a POST request to '/clouds/<cloud_id>/instances'" do
      intercepted_calls["clouds/cloud_under_test/instances"].
          should_receive(:post).with(%r#^\{("role_ids":\["r1","r2"\]|"instance_type":"m1.small"|,)+\}$#).
          and_return('{"id":"instance_created"}')

      cloud.create_instance({:role_ids => %w[r1 r2], :instance_type => "m1.small"})
    end

    it "returns an instance of Instance based on the returned properties" do
      intercepted_calls["clouds/cloud_under_test/instances"].should_receive(:post).
          and_return('{"id":"instance_created","role_ids":["r1","r2"]}')

      instance = cloud.create_instance({})
      instance.should be
      instance.should be_instance_of(Instance)
      instance.id.should == "instance_created"
      instance['role_ids'].should == %w[r1 r2]
    end

    it "returns an instance of Instance bound to the cloud's nested instance path" do
      intercepted_calls["clouds/cloud_under_test/instances"].should_receive(:post).
          and_return('{"id":"instance_created"}')

      instance = cloud.create_instance({})
      instance.should be

      intercepted_calls["clouds/cloud_under_test/instances/instance_created"].should_receive(:get).
          and_return('{"id":"instance_created"}')
      instance.reload(true)
    end
  end
end

module Scalapi
  describe Cloud, "#create_role(attributes)" do
    before do
      intercept_scalapi_calls
    end

    let(:cloud) {
      Cloud.new("cloud_under_test")
    }

    it "sends a POST request to '/clouds/<cloud_id>/roles'" do
      intercepted_calls["clouds/cloud_under_test/roles"].
          should_receive(:post).with('{"name":"forward"}').
          and_return('{"id":"role_created"}')

      cloud.create_role({:name => "forward"})
    end

    it "returns an instance of Role based on the returned properties" do
      intercepted_calls["clouds/cloud_under_test/roles"].should_receive(:post).
          and_return('{"id":"role_created","name":"forward"}')

      role = cloud.create_role({})
      role.should be
      role.should be_instance_of(Role)
      role.id.should == "role_created"
      role['name'].should == "forward"
    end

    it "returns an instance of Instance bound to the cloud's nested role path" do
      intercepted_calls["clouds/cloud_under_test/roles"].should_receive(:post).
          and_return('{"id":"role_created"}')

      role = cloud.create_role({})
      role.should be

      intercepted_calls["clouds/cloud_under_test/roles/role_created"].should_receive(:get).
          and_return('{"id":"role_created"}')
      role.reload(true)
    end
  end
end

