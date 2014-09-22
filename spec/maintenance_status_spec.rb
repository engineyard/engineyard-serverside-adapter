require 'spec_helper'

describe EY::Serverside::Adapter::MaintenanceStatus do
  let(:serverside_version) { "2.5.0" }
  it_should_behave_like "it installs engineyard-serverside"

  it_should_behave_like "it accepts app"
  it_should_behave_like "it accepts account_name"
  it_should_behave_like "it accepts environment_name"
  it_should_behave_like "it accepts account_name"
  it_should_behave_like "it accepts instances"
  it_should_behave_like "it accepts verbose"
  it_should_behave_like "it accepts serverside_version", '2.5.1'

  it_should_require :app
  it_should_require :environment_name
  it_should_require :account_name
  it_should_require :instances
  it_should_require :serverside_version

  it_should_behave_like "it treats config as optional"

  context "with valid arguments" do
    let(:command) do
      adapter = described_class.new do |arguments|
        arguments.app                = "rackapp"
        arguments.environment_name   = "rackapp_production"
        arguments.account_name       = "ey"
        arguments.instances          = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        arguments.serverside_version = serverside_version
      end
      last_command(adapter)
    end

    it "invokes exactly the right command" do
      command.should == [
        "engineyard-serverside",
        "_#{serverside_version}_",
        "maintenance_status",
        "--account-name ey",
        "--app rackapp",
        "--environment-name rackapp_production",
        "--instance-names localhost:chewie",
        "--instance-roles localhost:han,solo",
        "--instances localhost",
      ].join(' ')
    end

    it "blows up if serverside version is too old" do
      expect do
        described_class.new do |arguments|
          arguments.app                = "rackapp"
          arguments.environment_name   = "rackapp_production"
          arguments.account_name       = "ey"
          arguments.instances          = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
          arguments.serverside_version = "2.4.0"
        end
      end.to raise_error
    end
  end
end
