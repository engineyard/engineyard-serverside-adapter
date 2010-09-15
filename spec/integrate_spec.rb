require 'spec_helper'

describe EY::Serverside::Adapter::Integrate do
  it_should_behave_like "it accepts app"
  it_should_behave_like "it accepts framework_env"
  it_should_behave_like "it accepts instances"
  it_should_behave_like "it accepts stack"
  it_should_behave_like "it accepts verbose"

  it_should_require :app
  it_should_require :stack
  it_should_require :instances
  it_should_require :framework_env

  context "with valid arguments" do
    let(:command) do
      adapter = described_class.new do |builder|
        builder.app = "rackapp"
        builder.instances = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        builder.stack = "nginx_unicorn"
        builder.framework_env = "production"
      end
      adapter.call {|cmd| cmd}
    end

    it "invokes exactly the right command" do
      command.should == "engineyard-serverside _#{EY::Serverside::Adapter::VERSION}_ integrate --app rackapp --framework-env production --instance-names localhost:chewie --instance-roles localhost:han,solo --instances localhost --stack nginx_unicorn"
    end
  end
end
