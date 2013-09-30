require 'spec_helper'

describe EY::Serverside::Adapter::Rollback do
  it_should_behave_like "it installs engineyard-serverside"

  it_should_behave_like "it accepts app"
  it_should_behave_like "it accepts environment_name"
  it_should_behave_like "it accepts account_name"
  it_should_behave_like "it accepts framework_env"
  it_should_behave_like "it accepts instances"
  it_should_behave_like "it accepts stack"
  it_should_behave_like "it accepts verbose"
  it_should_behave_like "it accepts serverside_version"

  it_should_require :app
  it_should_require :environment_name, %w[2.0.0 2.1.0 2.2.0 2.3.0]
  it_should_require :account_name,     %w[2.0.0 2.1.0 2.2.0 2.3.0]
  it_should_require :framework_env
  it_should_require :instances
  it_should_require :stack
  it_should_require :serverside_version

  it_should_ignore_requirement :environment_name, '1.6.4'
  it_should_ignore_requirement :account_name,     '1.6.4'

  it_should_exclude_from_command :environment_name, %w[1.6.4]
  it_should_exclude_from_command :account_name,     %w[1.6.4]

  context "with valid arguments" do
    let(:command) do
      adapter = described_class.new do |arguments|
        arguments.app                = "rackapp"
        arguments.environment_name   = "rackapp_production"
        arguments.account_name       = "ey"
        arguments.framework_env      = 'production'
        arguments.instances          = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        arguments.stack              = "nginx_unicorn"
        arguments.config             = {'a' => 1}
        arguments.serverside_version = serverside_version
      end
      last_command(adapter)
    end

    it "puts the config in the command line as json" do
      command.should =~ /--config '#{Regexp.quote '{"a":1}'}'/
    end

    it "invokes exactly the right command" do
      command.should == [
        "engineyard-serverside",
        "_#{serverside_version}_",
        "deploy rollback",
        "--account-name ey",
        "--app rackapp",
        "--config '{\"a\":1}'",
        "--environment-name rackapp_production",
        "--framework-env production",
        "--instance-names localhost:chewie",
        "--instance-roles localhost:han,solo",
        "--instances localhost",
        "--stack nginx_unicorn",
      ].join(' ')
    end
  end
end
