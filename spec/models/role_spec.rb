# encoding: utf-8
#
# Copyright (c) Infopark AG
#
require File.expand_path("../../spec_helper.rb", __FILE__)

module Scalapi
  describe Role, "#instances" do
    before do
      intercept_scalapi_calls
      intercepted_calls[instances_path].stub(:get).and_return('[]')
    end

    let(:role) {
      instantiate_model("under_test", :class => Role, :base => "clouds/c/roles")
    }

    let(:role_path) {
      "clouds/c/roles/under_test"
    }

    let(:instances_path) {
      role_path + "/instances"
    }

    it "sends a GET request to the nested 'instances' url" do
      intercepted_calls[role_path + "/instances"].should_receive(:get).
          and_return('[{"id":"instance1"},{"id":"instance2"}]')
      role.instances.should be
    end

    it "returns instances of Instance using the response properties" do
      intercepted_calls[instances_path].should_receive(:get).
          and_return('[{"id":"instance1"},{"id":"instance2"}]')
      (instances = role.instances).should be

      instances.should be_instance_of(Array)
      instances.should be_all{|s| s.kind_of?(Instance)}
      instances.should have(2).items
      instances.map {|s| s.id}.should == %w[instance1 instance2]
    end

    it "returns instances of Instance bound to a sibling url instead of a nested url" do
      intercepted_calls[instances_path].should_receive(:get).
          and_return('[{"id":"instance1"},{"id":"instance2"}]')
      (instances = role.instances).should be

      intercepted_calls["clouds/c/instances/instance1"].should_receive(:get).
          and_return('{"id":"instance1"}')

      instances.first.reload(true)
    end
  end
end
