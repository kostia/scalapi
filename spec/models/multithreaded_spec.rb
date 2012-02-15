require 'spec_helper'

describe Scalapi, "when run multithreaded" do
  before do
    intercept_scalapi_calls

    intercepted_calls["clouds/c/roles"].stub(:post) do |arg|
      sleep rand / 8.0
      '{"id":"irrelevant"}'
    end
  end

  it "shows same behaviour" do
    expect {
      threads = 100.times.map do |i|
        Thread.new do
          Scalapi::Cloud.new("c").create_role(:name => i.to_s)
        end
      end
      threads.each {|t| t.join}
    }.to_not raise_error
  end
end
