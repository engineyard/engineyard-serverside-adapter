require 'spec_helper'

shared_examples_for "a serverside action" do
  before(:each) do
    @adapter = described_class.new do |args|
      args.app              = 'app-from-adapter-new'
      args.environment_name = 'env-from-adapter-new'
      args.account_name     = 'acc-from-adapter-new'
      args.instances        = [{:hostname => 'localhost', :roles => %w[a b c]}]
      args.framework_env    = 'production'
      args.ref              = 'master'
      args.repo             = 'git@github.com:engineyard/engineyard-serverside.git'
      args.stack            = 'nginx_unicorn'
      args
    end
  end

  it "gives you an Arguments already set up from when you instantiated the adapter" do
    command = @adapter.send(@method) do |args|
      args.app.should == 'app-from-adapter-new'
    end
  end

  it "applies both sets of changes" do
    action = @adapter.send(@method) do |args|
      args.verbose = true
    end

    command = last_command(action)
    command.should include('--app app-from-adapter-new')
    command.should include('--verbose')
  end

  it "returns true when all commands succeed in call" do
    action = @adapter.send(@method) do |args|
      args.verbose = true
    end

    commands = []
    action.call { |cmd| commands << cmd; true }.should be_true
    commands.should have(2).entries
  end

  it "returns false when any commands fail in call, short circuiting if first command fails" do
    action = @adapter.send(@method) do |args|
      args.verbose = true
    end

    commands = []
    action.call { |cmd| commands << cmd; false }.should be_false
    commands.should have(1).entries

    commands = []
    action.call { |cmd| commands << cmd; commands.size == 1 ? true : false }.should be_false
    commands.should have(2).entries
  end

  it "does not let arguments changes propagate back up to the adapter" do
    command1 = @adapter.send(@method) do |args|
      args.app = 'sporkr'
    end

    @adapter.send(@method) do |args|
      args[:app].should == 'app-from-adapter-new'
    end
  end

  context "with no pathname specified" do
    it "begins both commands with no path" do
      action = @adapter.send(@method) do |args|
        args.verbose = true
      end

      commands = all_commands(action)
      commands.first.should =~ /^\(gem/
      commands.last.should =~ /^engineyard-serverside/
    end
  end

  context "with a pathname specified" do
    it "begins both commands with the given path" do
      adapter = described_class.new("/usr/local/grin") do |args|
        args.app              = 'app-from-adapter-new'
        args.environment_name = 'env-from-adapter-new'
        args.account_name     = 'acc-from-adapter-new'
        args.instances        = [{:hostname => 'localhost', :roles => %w[a b c]}]
        args.framework_env    = 'production'
        args.ref              = 'master'
        args.repo             = 'git@github.com:engineyard/engineyard-serverside.git'
        args.stack            = 'nginx_unicorn'
        args
      end

      action = adapter.send(@method) do |args|
        args.verbose = true
      end

      commands = all_commands(action)
      commands.first.should =~ %r{^\(/usr/local/grin/gem}
      commands.last.should =~ %r{^/usr/local/grin/engineyard-serverside}
    end
  end

  context "with an alternate serverside_version specified" do
    it "uses the given version for the gem install and serverside commands" do
      action = @adapter.send(@method) do |args|
        args.serverside_version = '1.6.4'
      end

      commands = all_commands(action)
      commands.first.should == "(gem list engineyard-serverside | grep 'engineyard-serverside ' | egrep -q '1\\.6\\.4[,)]') || (sudo sh -c 'cd `mktemp -d` && gem install engineyard-serverside --no-rdoc --no-ri -v 1.6.4')"
      commands.last.should =~ /engineyard-serverside _1\.6\.4_/
      commands.last.should_not =~ /--environment-name/ # 2.0.0 and above only
      commands.last.should_not =~ /--account-name/ # 2.0.0 and above only
    end
  end
end

describe EY::Serverside::Adapter do
  context ".new" do
    it "lets you access the arguments" do
      adapter = described_class.new do |args|
        args.app = 'myapp'
      end
    end

    it "does not require a block" do
      lambda { described_class.new }.should_not raise_error
    end
  end

  [
    :deploy,
    :disable_maintenance,
    :enable_maintenance,
    :integrate,
    :restart,
    :rollback,
  ].each do |method|
    context "##{method}" do
      before { @method = method }
      it_should_behave_like "a serverside action"
    end
  end

  context "mapping of methods to action classes" do
    before(:each) do
      @adapter = described_class.new do |args|
        args.app              = 'app-from-adapter-new'
        args.environment_name = 'env-from-adapter-new'
        args.account_name     = 'acc-from-adapter-new'
        args.instances        = [{:hostname => 'localhost', :roles => %w[a b c]}]
        args.framework_env    = 'production'
        args.ref              = 'master'
        args.repo             = 'git@github.com:engineyard/engineyard-serverside.git'
        args.stack            = 'nginx_unicorn'
        args
      end
    end

    it "gives you the right command" do
      @adapter.enable_maintenance.should  be_kind_of(EY::Serverside::Adapter::EnableMaintenance)
      @adapter.disable_maintenance.should be_kind_of(EY::Serverside::Adapter::DisableMaintenance)
      @adapter.deploy.should              be_kind_of(EY::Serverside::Adapter::Deploy)
      @adapter.integrate.should           be_kind_of(EY::Serverside::Adapter::Integrate)
      @adapter.rollback.should            be_kind_of(EY::Serverside::Adapter::Rollback)
    end
  end

end
