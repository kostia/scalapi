# encoding: utf-8
#
# Copyright (c) Infopark AG
#
require File.expand_path("../../spec_helper.rb", __FILE__)

module Scalapi
  describe Application do
    before do
      intercept_scalapi_calls
    end

    let(:application) {
      Application.new("application_under_test")
    }

    describe "#deployments" do
      it "sends a GET request to applications/application_under_test/deployments" do
        intercepted_calls["applications/application_under_test/deployments"].
            should_receive(:get).and_return('[{"id":"deployment1"},{"id":"deployment2"}]')
        application.deployments
      end

      it "returns instances of Deployment" do
        intercepted_calls["applications/application_under_test/deployments"].
            should_receive(:get).and_return('[{"id":"deployment1"},{"id":"deployment2"}]')
        (deployments = application.deployments).should be
        deployments.should be_instance_of(Array)
        deployments.should be_all{|c| c.kind_of?(Deployment)}
        deployments.should have(2).items
        deployments.map {|c| c.id}.should == %w[deployment1 deployment2]
      end
    end
  end
end
