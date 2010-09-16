require 'spec_helper'

describe EY::Serverside::Adapter::Restart do
  it_should_behave_like "it installs engineyard-serverside"

  it_should_behave_like "it accepts app"
  it_should_behave_like "it accepts instances"
  it_should_behave_like "it accepts stack"
  it_should_behave_like "it accepts verbose"

  it_should_require :app
  it_should_require :instances
  it_should_require :stack

  context "with valid arguments" do
    let(:command) do
      adapter = described_class.new do |arguments|
        arguments.app           = "rackapp"
        arguments.instances     = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        arguments.stack         = "nginx_unicorn"
      end
      last_command(adapter)
    end

    it "invokes exactly the right command" do
      command.should == "engineyard-serverside _#{EY::Serverside::Adapter::ENGINEYARD_SERVERSIDE_VERSION}_ restart --app rackapp --instance-names localhost:chewie --instance-roles localhost:han,solo --instances localhost --stack nginx_unicorn"
    end
  end
end
