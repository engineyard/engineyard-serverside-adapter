require 'spec_helper'

describe EY::Serverside::Adapter::Deploy do
  it_should_behave_like "it installs engineyard-serverside"

  it_should_behave_like "it accepts app"
  it_should_behave_like "it accepts account_name"
  it_should_behave_like "it accepts archive"
  it_should_behave_like "it accepts environment_name"
  it_should_behave_like "it accepts framework_env"
  it_should_behave_like "it accepts git"
  it_should_behave_like "it accepts instances"
  it_should_behave_like "it accepts migrate"
  it_should_behave_like "it accepts ref"
  it_should_behave_like "it accepts stack"
  it_should_behave_like "it accepts verbose"
  it_should_behave_like "it accepts serverside_version"

  it_should_require :app
  it_should_require :environment_name, %w[2.0.0 2.1.0 2.2.0 2.3.0]
  it_should_require :account_name,     %w[2.0.0 2.1.0 2.2.0 2.3.0]
  it_should_require :instances
  it_should_require :framework_env
  it_should_require :stack
  it_should_require :ref,  %w[1.6.4 2.0.0 2.1.0 2.2.0]
  it_should_require :git,  %w[1.6.4 2.0.0 2.1.0 2.2.0]
  it_should_require :serverside_version

  it_should_ignore_requirement :environment_name, '1.6.4'
  it_should_ignore_requirement :account_name,     '1.6.4'
  it_should_ignore_requirement :ref,              '2.3.0'

  it_should_exclude_from_command :environment_name, %w[1.6.4]
  it_should_exclude_from_command :account_name,     %w[1.6.4]
  it_should_exclude_from_command :repo,             %w[2.3.0]
  it_should_exclude_from_command :git,              %w[1.6.4 2.0.0 2.1.0 2.2.0]
  it_should_exclude_from_command :archive,          %w[1.6.4 2.0.0 2.1.0 2.2.0]

  it_should_behave_like "it treats config as optional"
  it_should_behave_like "it treats migrate as optional"

  context "with valid arguments" do
    def deploy_command(&block)
      adapter = described_class.new do |arguments|
        arguments.app                = "rackapp"
        arguments.environment_name   = 'rackapp_production'
        arguments.account_name       = 'ey'
        arguments.framework_env      = 'production'
        arguments.config             = {'a' => 1}
        arguments.instances          = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        arguments.migrate            = 'rake db:migrate'
        arguments.ref                = 'master'
        arguments.git                = 'git@github.com:engineyard/engineyard-serverside.git'
        arguments.stack              = "nginx_unicorn"
        arguments.serverside_version = serverside_version
        block.call arguments if block
      end
      last_command(adapter)
    end

    def archive_deploy_command(&block)
      adapter = described_class.new do |arguments|
        arguments.archive            = 'https://github.com/engineyard/engineyard-serverside/archive/master.zip'
        arguments.app                = "rackapp"
        arguments.environment_name   = 'rackapp_production'
        arguments.account_name       = 'ey'
        arguments.framework_env      = 'production'
        arguments.config             = {'a' => 1}
        arguments.instances          = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        arguments.migrate            = 'rake db:migrate'
        arguments.stack              = "nginx_unicorn"
        arguments.serverside_version = serverside_version
        block.call arguments if block_given?
      end
      last_command(adapter)
    end

    it "puts the config in the command line as json" do
      deploy_command.should =~ /--config '#{Regexp.quote '{"a":1}'}'/
    end

    it "invokes exactly the right command" do
      deploy_command.should == [
        "engineyard-serverside",
        "_#{serverside_version}_",
        "deploy",
        "--account-name ey",
        "--app rackapp",
        "--config '{\"a\":1}'",
        "--environment-name rackapp_production",
        "--framework-env production",
        "--git git@github.com:engineyard/engineyard-serverside.git",
        "--instance-names localhost:chewie",
        "--instance-roles localhost:han,solo",
        "--instances localhost",
        "--migrate 'rake db:migrate'",
        "--ref master",
        "--stack nginx_unicorn",
      ].join(' ')
    end

    %w[1.6.4 2.0.0 2.1.0 2.2.0].each do |version|
      context "on version ~> #{version}" do
        it "sets --repo instead of --git flag" do
          git_repo = 'git@github.com:engineyard/engineyard-serverside.git'
          command = deploy_command do |args|
            args.serverside_version = version
            args.git = git_repo
          end

          expect(command).to match(/--repo #{Regexp.escape(git_repo)}/)
          expect(command).not_to match(/--git/)
        end

        it "raises if both --archive and --git are set (you must specify git)" do
          expect do
            command = deploy_command do |args|
              args.archive            = "url"
              args.serverside_version = version
            end
          end.to raise_error(ArgumentError)
        end
      end
    end

    context "on version ~> 2.3.0" do
      let(:version) { "2.3.0" }

      it "sets --git and not --repo flag" do
        git_repo = 'git@github.com:engineyard/engineyard-serverside.git'
        command = deploy_command do |args|
          args.serverside_version = version
          args.git = git_repo
        end
        expect(command).to match(/--git #{Regexp.escape(git_repo)}/)
        expect(command).not_to match(/--repo/)
      end

      it "raises if both --archive and --git are set" do
        expect do
          deploy_command do |args|
            args.serverside_version = version
            args.archive = "url"
          end
        end.to raise_error(ArgumentError)
      end

      it "raises if neither --archive nor --git are set" do
        expect do
          described_class.new do |arguments|
            arguments.app                = "rackapp"
            arguments.environment_name   = 'rackapp_production'
            arguments.account_name       = 'ey'
            arguments.framework_env      = 'production'
            arguments.config             = {'a' => 1}
            arguments.instances          = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
            arguments.migrate            = 'rake db:migrate'
            arguments.ref                = 'master'
            arguments.stack              = "nginx_unicorn"
            arguments.serverside_version = version
          end
        end.to raise_error(ArgumentError)
      end

      it "sets --archive" do
        command = archive_deploy_command do |args|
          args.serverside_version = version
          args.archive = "url"
        end
        expect(command).to match(/--archive url/)
      end
    end
  end

  context "with git deploy" do
    let(:command) do
      adapter = described_class.new do |arguments|
        arguments.app                = "rackapp"
        arguments.environment_name   = 'rackapp_production'
        arguments.account_name       = 'ey'
        arguments.framework_env      = 'production'
        arguments.config             = {'a' => 1}
        arguments.instances          = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        arguments.migrate            = 'rake db:migrate'
        arguments.ref                = 'master'
        arguments.git                = 'git@github.com:engineyard/engineyard-serverside.git'
        arguments.stack              = "nginx_unicorn"
        arguments.serverside_version = '2.3.0'
      end
      last_command(adapter)
    end

    it "invokes exactly the right command" do
      command.should == [
        "engineyard-serverside",
        "_2.3.0_",
        "deploy",
        "--account-name ey",
        "--app rackapp",
        "--config '{\"a\":1}'",
        "--environment-name rackapp_production",
        "--framework-env production",
        "--git git@github.com:engineyard/engineyard-serverside.git",
        "--instance-names localhost:chewie",
        "--instance-roles localhost:han,solo",
        "--instances localhost",
        "--migrate 'rake db:migrate'",
        "--ref master",
        "--stack nginx_unicorn"
      ].join(' ')
    end
  end

  context "with package deploy" do
    let(:command) do
      adapter = described_class.new do |args|
        args.app              = "rackapp"
        args.environment_name = 'rackapp_production'
        args.account_name     = 'ey'
        args.framework_env    = 'production'
        args.instances        = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        args.migrate          = false
        args.stack            = "nginx_unicorn"
        args.archive          = 'https://github.com/engineyard/engineyard-serverside/archive/master.zip'
        args.serverside_version = '2.3.0'
      end

      last_command(adapter)
    end

    it "invokes exactly the right command" do
      command.should == [
        "engineyard-serverside",
        "_2.3.0_",
        "deploy",
        "--account-name ey",
        "--app rackapp",
        "--archive https://github.com/engineyard/engineyard-serverside/archive/master.zip",
        "--environment-name rackapp_production",
        "--framework-env production",
        "--instance-names localhost:chewie",
        "--instance-roles localhost:han,solo",
        "--instances localhost",
        "--no-migrate",
        "--stack nginx_unicorn"
      ].join(' ')
    end

  end

  context "with no migrate argument" do
    let(:command) do
      adapter = described_class.new do |arguments|
        arguments.app              = "rackapp"
        arguments.environment_name = 'rackapp_production'
        arguments.account_name     = 'ey'
        arguments.framework_env    = 'production'
        arguments.config           = {'a' => 1}
        arguments.instances        = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        arguments.migrate          = false
        arguments.ref              = 'master'
        arguments.git              = 'git@github.com:engineyard/engineyard-serverside.git'
        arguments.stack            = "nginx_unicorn"
        arguments.serverside_version = '2.3.0'
      end
      last_command(adapter)
    end

    it "puts the config in the command line as json" do
      command.should =~ /--config '#{Regexp.quote '{"a":1}'}'/
    end

    it "invokes exactly the right command" do
      command.should == [
        "engineyard-serverside",
        "_2.3.0_",
        "deploy",
        "--account-name ey",
        "--app rackapp",
        "--config '{\"a\":1}'",
        "--environment-name rackapp_production",
        "--framework-env production",
        "--git git@github.com:engineyard/engineyard-serverside.git",
        "--instance-names localhost:chewie",
        "--instance-roles localhost:han,solo",
        "--instances localhost",
        "--no-migrate",
        "--ref master",
        "--stack nginx_unicorn",
      ].join(' ')
    end
  end
end
