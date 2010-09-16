require 'spec_helper'

describe EY::Serverside::Adapter::Deploy do
  it_should_behave_like "it installs engineyard-serverside"

  it_should_behave_like "it accepts app"
  it_should_behave_like "it accepts framework_env"
  it_should_behave_like "it accepts instances"
  it_should_behave_like "it accepts migrate"
  it_should_behave_like "it accepts ref"
  it_should_behave_like "it accepts repo"
  it_should_behave_like "it accepts stack"
  it_should_behave_like "it accepts verbose"

  it_should_require :app
  it_should_require :instances
  it_should_require :framework_env
  it_should_require :ref
  it_should_require :repo
  it_should_require :stack

  it_should_behave_like "it treats config as optional"
  it_should_behave_like "it treats migrate as optional"

  context "with valid arguments" do
    let(:command) do
      adapter = described_class.new do |arguments|
        arguments.app = "rackapp"
        arguments.framework_env = 'production'
        arguments.config = {'a' => 1}
        arguments.instances = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        arguments.migrate = 'rake db:migrate'
        arguments.ref = 'master'
        arguments.repo = 'git@github.com:engineyard/engineyard-serverside.git'
        arguments.stack = "nginx_unicorn"
      end
      last_command(adapter)
    end

    it "puts the config in the command line as json" do
      command.should =~ /--config '#{Regexp.quote '{"a":1}'}'/
    end

    it "invokes exactly the right command" do
      command.should == "engineyard-serverside _#{EY::Serverside::Adapter::ENGINEYARD_SERVERSIDE_VERSION}_ deploy --app rackapp --config '{\"a\":1}' --framework-env production --instance-names localhost:chewie --instance-roles localhost:han,solo --instances localhost --migrate 'rake db:migrate' --ref master --repo git@github.com:engineyard/engineyard-serverside.git --stack nginx_unicorn"
    end
  end
end
