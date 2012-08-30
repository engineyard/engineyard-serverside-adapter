require 'spec_helper'

describe EY::Serverside::Adapter::DisableMaintenance do
  it_should_behave_like "it installs engineyard-serverside"

  it_should_behave_like "it accepts app"
  it_should_behave_like "it accepts environment_name"
  it_should_behave_like "it accepts account_name"
  it_should_behave_like "it accepts instances"
  it_should_behave_like "it accepts verbose"
  it_should_behave_like "it accepts serverside_version"

  it_should_require :app
  it_should_require :environment_name
  it_should_require :account_name
  it_should_require :instances

  it_should_ignore_requirement_for_version :environment_name, '1.6.4'
  it_should_ignore_requirement_for_version :account_name,     '1.6.4'

  context "with valid arguments" do
    let(:command) do
      adapter = described_class.new do |arguments|
        arguments.app              = "rackapp"
        arguments.environment_name = "rackapp_production"
        arguments.account_name     = "ey"
        arguments.instances        = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
      end
      last_command(adapter)
    end

    it "invokes exactly the right command" do
      command.should == [
        "engineyard-serverside",
        "_#{EY::Serverside::Adapter::ENGINEYARD_SERVERSIDE_VERSION}_",
        "disable_maintenance",
        "--account-name ey",
        "--app rackapp",
        "--environment-name rackapp_production",
        "--instance-names localhost:chewie",
        "--instance-roles localhost:han,solo",
        "--instances localhost",
      ].join(' ')
    end
  end
end
