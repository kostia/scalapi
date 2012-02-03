# encoding: utf-8
#
# Copyright (c) Infopark AG
#
require File.expand_path("../../spec_helper.rb", __FILE__)

module Scalapi
  describe Volume, "#snapshots" do
    before do
      intercept_scalapi_calls
      intercepted_calls["snapshots"].stub(:get).and_return('[]')
    end

    let(:volume) {
      Volume.new("volume_under_test")
    }

    it "sends a GET request to '/volumes/<volume_id>/snapshots'" do
      intercepted_calls["volumes/volume_under_test/snapshots"].should_receive(:get).
          and_return('[{"id":"snapshot1"},{"id":"snapshot2"}]')
      volume.snapshots.should be
    end

    it "returns instances of Snapshot using the response properties" do
      intercepted_calls["volumes/volume_under_test/snapshots"].should_receive(:get).
          and_return('[{"id":"snapshot1"},{"id":"snapshot2"}]')
      (snapshots = volume.snapshots).should be

      snapshots.should be_instance_of(Array)
      snapshots.should be_all{|s| s.kind_of?(Snapshot)}
      snapshots.should have(2).items
      snapshots.map {|s| s.id}.should == %w[snapshot1 snapshot2]
    end
  end
end

module Scalapi
  describe Volume, "#create_snapshot(attributes)" do
    let(:volume) {
      Volume.new("volume_under_test")
    }

    before do
      intercept_scalapi_calls
      intercepted_calls["volumes/volume_under_test/snapshots"].stub(:post).
          and_return('{"id":"snap-26050a46"}')
    end

    it "sends a POST request to '/volumes/<v_id>/snapshots'" do
      intercepted_calls["volumes/volume_under_test/snapshots"].should_receive(:post).
          with(nil).and_return('{"id":"snap-26050a46"}')
      volume.create_snapshot.should be
    end

    it "returns an instance of Snapshot based on the returned values" do
      intercepted_calls["volumes/volume_under_test/snapshots"].should_receive(:post).
          with(nil).and_return('{"id":"snap-1234","progress":"0%"}')
      (snapshot = volume.create_snapshot).should be
      snapshot.should be_instance_of(Snapshot)
      snapshot.id.should == "snap-1234"
      snapshot['progress'].should == "0%"
    end
  end
end

module Scalapi
  describe Volume, ".new(id) # created for default scalarium without request" do
    before do
      intercept_scalapi_calls
      intercepted_calls["volumes/volume_under_test"].stub(:get).
          and_return('{"id":"volume_under_test"}')
    end

    let(:volume) {
      Volume.new("volume_under_test")
    }

    describe "when accessing attributes" do
      it "sends a GET request to '/volumes/<id>'" do
        intercepted_calls["volumes/volume_under_test"].should_receive(:get).
            with(no_args).and_return('{"id":"volume_under_test","status":"in-use"}')
        volume['status']
      end

      it "returns the property value based on the GET response" do
        intercepted_calls["volumes/volume_under_test"].should_receive(:get).
            with(no_args).and_return('{"id":"volume_under_test","status":"in-use"}')
        volume['status'].should == "in-use"
      end
    end
  end
end
