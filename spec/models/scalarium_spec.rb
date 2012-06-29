# encoding: utf-8
#
# Copyright (c) Infopark AG
#
require File.expand_path("../../spec_helper.rb", __FILE__)

module Scalapi
  describe Scalarium, "#applications" do
    before do
      intercept_scalapi_calls
      intercepted_calls["applications"].stub(:get).and_return('[]')
    end

    let(:scalarium) {
      Scalapi.scalarium
    }

    it "sends a GET request to /applications" do
      intercepted_calls["applications"].should_receive(:get).
          and_return('[{"id":"application1"},{"id":"application2"}]')
      scalarium.applications.should be
    end

    it "returns instances of Application" do
      intercepted_calls["applications"].should_receive(:get).
          and_return('[{"id":"application1"},{"id":"application2"}]')
      (applications = scalarium.applications).should be

      applications.should be_instance_of(Array)
      applications.should be_all{|c| c.kind_of?(Application)}
      applications.should have(2).items
      applications.map {|c| c.id}.should == %w[application1 application2]
    end
  end

  describe Scalarium, "#create_application(attributes)" do
    before do
      intercept_scalapi_calls
    end

    let(:scalarium) {
      Scalapi.scalarium
    }

    it "should raise an error suggesting to call a cloud's instance method" do
      expect {
        scalarium.create_application(:name => "infopark-cms")
      }.to raise_error(/available .* cloud instance method/)
    end
  end

  describe Scalarium, "#find_application(id)" do
    before do
      intercept_scalapi_calls
    end

    let(:scalarium) {
      Scalapi.scalarium
    }

    it "sends a GET request to '/applications/<id>'" do
      intercepted_calls["applications/application_one"].should_receive(:get).
          and_return('{"id":"application_one"}')
      scalarium.find_application("application_one").should be
    end

    context "when the application exists" do
      before do
        intercepted_calls["applications/application_one"].stub(:get).and_return('{"id":"application_one"}')
      end

      it "returns an instance of Application based on the returned properties" do
        intercepted_calls["applications/application_one"].stub(:get).
            and_return('{"id":"application_one","name":"name of the application"}')
        (application = scalarium.find_application("application_one")).should be
        application.should be_instance_of(Application)
        application.id.should == "application_one"
        application['name'].should == "name of the application"
      end
    end
  end
end

module Scalapi
  describe Scalarium, "#clouds" do
    before do
      intercept_scalapi_calls
      intercepted_calls["clouds"].stub(:get).and_return('[]')
    end

    let(:scalarium) {
      Scalapi.scalarium
    }

    it "sends a GET request to /clouds" do
      intercepted_calls["clouds"].should_receive(:get).
          and_return('[{"id":"cloud1"},{"id":"cloud2"}]')
      scalarium.clouds.should be
    end

    it "returns instances of Cloud" do
      intercepted_calls["clouds"].should_receive(:get).
          and_return('[{"id":"cloud1"},{"id":"cloud2"}]')
      (clouds = scalarium.clouds).should be

      clouds.should be_instance_of(Array)
      clouds.should be_all{|c| c.kind_of?(Cloud)}
      clouds.should have(2).items
      clouds.map {|c| c.id}.should == %w[cloud1 cloud2]
    end
  end

  describe Scalarium, "#create_cloud(attributes)" do
    before do
      intercept_scalapi_calls
      intercepted_calls["clouds"].stub(:post).and_return('{}')
    end

    let(:scalarium) {
      Scalapi.scalarium
    }

    it "sends a POST request to '/clouds with JSON encoded attributes" do
      intercepted_calls["clouds"].should_receive(:post).
          with('{"name":"wolke"}').and_return('{"id":"neu"}')
      scalarium.create_cloud(:name => "wolke").should be
    end

    it "returns an instance of Cloud based on the returned properties" do
      intercepted_calls["clouds"].should_receive(:post).
          with('{"name":"wolke"}').and_return('{"id":"neu","custom_json":{"key":"value"}}')
      (cloud = scalarium.create_cloud(:name => "wolke")).should be
      cloud.should be_instance_of(Cloud)
      cloud.id.should == "neu"
      cloud['custom_json'].should == {"key" => "value"}
    end
  end

  describe Scalarium, "#find_cloud(id)" do
    before do
      intercept_scalapi_calls
    end

    let(:scalarium) {
      Scalapi.scalarium
    }

    it "sends a GET request to '/clouds/<id>'" do
      intercepted_calls["clouds/cloud_one"].should_receive(:get).
          and_return('{"id":"cloud_one"}')
      scalarium.find_cloud("cloud_one").should be
    end

    context "when the cloud exists" do
      before do
        intercepted_calls["clouds/cloud_one"].stub(:get).and_return('{"id":"cloud_one"}')
      end

      it "returns an instance of Cloud based on the returned properties" do
        intercepted_calls["clouds/cloud_one"].stub(:get).
            and_return('{"id":"cloud_one","name":"name of the cloud"}')
        (cloud = scalarium.find_cloud("cloud_one")).should be
        cloud.should be_instance_of(Cloud)
        cloud.id.should == "cloud_one"
        cloud['name'].should == "name of the cloud"
      end
    end

    context "when the id is nil" do
      it "returns nil" do
        scalarium.find_cloud(nil).should == nil
      end

      it "does not send a request" do
        # intercept_scalapi_calls raises an error for every unexpected request
        scalarium.find_cloud(nil)
      end
    end
  end
end

module Scalapi
  describe Scalarium, "#delete_cloud(id)" do
    before do
      intercept_scalapi_calls
    end

    let(:scalarium) {
      Scalapi.scalarium
    }

    it "sends a DELETE request to /clouds/<cloud_id>" do
      intercepted_calls["clouds/c_id"].should_receive(:delete)
      scalarium.delete_cloud("c_id")
    end
  end
end

module Scalapi
  describe Scalarium, "#volumes" do
    before do
      intercept_scalapi_calls
      intercepted_calls["volumes"].stub(:get).and_return('[]')
    end

    let(:scalarium) {
      Scalapi.scalarium
    }

    it "sends a GET request to /volumes" do
      intercepted_calls["volumes"].should_receive(:get).
          and_return('[{"id":"volume"},{"id":"volume2"}]')
      scalarium.volumes.should be
    end

    it "returns instances of Volume" do
      intercepted_calls["volumes"].should_receive(:get).
          and_return('[{"id":"volume1"},{"id":"volume2"}]')
      (volumes = scalarium.volumes).should be
      volumes.should be_instance_of(Array)
      volumes.should be_all{|c| c.kind_of?(Volume)}
      volumes.should have(2).items
      volumes.map {|v| v.id}.should == %w[volume1 volume2]
    end
  end
end

module Scalapi
  describe Scalarium, "#delete_volume(id)" do
    before do
      intercept_scalapi_calls
    end

    let(:scalarium) {
      Scalapi.scalarium
    }

    it "sends a DELETE request to /volumes/<volume_id>" do
      intercepted_calls["volumes/v_id"].should_receive(:delete)
      scalarium.delete_volume("v_id")
    end
  end
end

module Scalapi
  describe Scalarium, "#credentials" do
    before do
      intercept_scalapi_calls
      intercepted_calls["credentials"].stub(:get).and_return('[]')
    end

    let(:scalarium) {
      Scalapi.scalarium
    }

    it "sends a GET request to /credentials" do
      intercepted_calls["credentials"].should_receive(:get).
          and_return('[{"id":"credential1"},{"id":"credential2"}]')
      scalarium.credentials
    end

    it "returns instances of Credential" do
      intercepted_calls["credentials"].should_receive(:get).
          and_return('[{"id":"credential1"},{"id":"credential2"}]')
      credentials = scalarium.credentials

      credentials.should be_instance_of(Array)
      credentials.should be_all{|c| c.kind_of?(Credential)}
      credentials.should have(2).items
      credentials.map {|c| c.id}.should == %w[credential1 credential2]
    end
  end

  describe Scalarium, "#create_credential(attributes)" do
    before do
      intercept_scalapi_calls
      intercepted_calls["credentials"].stub(:post).and_return('{}')
    end

    let(:scalarium) {
      Scalapi.scalarium
    }

    it "sends a POST request to '/credentials with JSON encoded attributes" do
      intercepted_calls["credentials"].should_receive(:post).
          with('{"name":"access"}').and_return('{"id":"neu"}')
      scalarium.create_credential(:name => "access")
    end

    it "returns an instance of Credential based on the returned properties" do
      intercepted_calls["credentials"].should_receive(:post).with('{"name":"access"}').
          and_return('{"id":"neu","aws_access_key_id":"key","aws_secret_access_key":"secret"}')
      credential = scalarium.create_credential(:name => "access")
      credential.should be_instance_of(Credential)
      credential.id.should == "neu"
      credential['aws_access_key_id'].should == "key"
      credential['aws_secret_access_key'].should == "secret"
    end
  end

  describe Scalarium, "#find_credential(id)" do
    before do
      intercept_scalapi_calls
    end

    let(:scalarium) {
      Scalapi.scalarium
    }

    it "sends a GET request to '/credentials/<id>'" do
      intercepted_calls["credentials/credential_one"].should_receive(:get).
          and_return('{"id":"credential_one"}')
      scalarium.find_credential("credential_one").should be
    end

    context "when the credential exists" do
      before do
        intercepted_calls["credentials/credential_one"].stub(:get).
            and_return('{"id":"credential_one"}')
      end

      it "returns an instance of credential based on the returned properties" do
        intercepted_calls["credentials/credential_one"].stub(:get).
            and_return('{"id":"credential_one","name":"name of the credential"}')

        credential = scalarium.find_credential("credential_one")
        credential.should be_instance_of(Credential)
        credential.id.should == "credential_one"
        credential['name'].should == "name of the credential"
      end
    end
  end
end

module Scalapi
  describe Scalarium, "#delete_credential(id)" do
    before do
      intercept_scalapi_calls
    end

    let(:scalarium) {
      Scalapi.scalarium
    }

    it "sends a DELETE request to /credentials/<credential_id>" do
      intercepted_calls["credentials/c_id"].should_receive(:delete)
      scalarium.delete_credential("c_id")
    end
  end
end
