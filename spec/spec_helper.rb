require 'rubygems'
require 'bundler/setup'

require 'engineyard-serverside-adapter'
require 'pp'

begin
  specs = Gem::SpecFetcher.fetcher.fetch(Gem::Dependency.new("engineyard-serverside"))
  ENGINEYARD_SERVERSIDE_VERSION = specs.map {|spec,| spec.version}.sort.last.to_s
rescue
  ENGINEYARD_SERVERSIDE_VERSION = '2.3.1'
end

module ArgumentsHelpers
  def serverside_version
    ENGINEYARD_SERVERSIDE_VERSION
  end

  def valid_options
    {
      :app                => 'rackapp',
      :account_name       => 'ey',
      #:archive            => 'https://github.com/engineyard/engineyard-serverside/archive/master.zip',
      :environment_name   => 'rackapp_production',
      :framework_env      => 'production',
      :git                => 'git@github.com:engineyard/engineyard-serverside.git',
      :instances          => [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}],
      :ref                => 'master',
      :stack              => 'nginx_unicorn',
      :serverside_version => serverside_version,
    }
  end

  def valid_arguments() arguments_without() end   # without nothing --> valid :)

  def arguments_with(fields)
    arguments = valid_arguments
    fields.each do |field, value|
      arguments.send("#{field}=", value)
    end
    arguments
  end

  def arguments_without(*fields)
    arguments = EY::Serverside::Adapter::Arguments.new
    valid_options.each do |field, value|
      arguments.send("#{field}=", value) unless fields.include?(field)
    end
    arguments
  end

  def all_commands(adapter)
    adapter.commands.map(&:to_s)
  end

  def last_command(adapter)
    all_commands(adapter).last
  end
end

module RequiredFieldHelpers
  def it_should_require(field, versions=[:all])
    context "field #{field}" do
      versions.each do |version|
        on_versions = version == :all ? "on all versions" : "on version ~> #{version}"
        context on_versions do
          it "is fine when #{field} is there" do
            arguments = valid_arguments
            arguments.serverside_version = version unless version == :all
            expect { described_class.new(:arguments => arguments) }.to_not raise_error
          end

          it "raises an error if #{field} is missing" do
            arguments = arguments_without(field)
            arguments.serverside_version = version unless version == :all
            expect { described_class.new(:arguments => arguments) }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end

  def it_should_ignore_requirement(field, version)
    context "field #{field}" do
      context "on version ~> #{version}" do
        it "is not required" do
          arguments = arguments_without(field)
          arguments.serverside_version = version
          lambda { described_class.new(:arguments => arguments) }.should_not raise_error
        end
      end
    end
  end

  def it_should_exclude_from_command(field, versions)
    context "field #{field}" do
      versions.each do |version|
        context "on version ~> #{version}" do
          it "is not included #{field} in the command" do
            arguments = valid_arguments
            arguments.serverside_version = version
            action = described_class.new(:arguments => arguments)
            commands = all_commands(action)
            commands.last.should_not include(EY::Serverside::Adapter::Option.new(field, :string).to_switch)
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include ArgumentsHelpers
  config.extend RequiredFieldHelpers

  shared_examples_for "it installs engineyard-serverside" do
    it "checks for and installs engineyard-serverside before invoking it" do
      adapter = described_class.new(:arguments => valid_arguments)

      all_commands(adapter).size.should == 2
      installation_command = all_commands(adapter).first

      # of course, the only way to be sure is to actually run it, but
      # this gives us regression-proofing
      version = serverside_version
      escaped_version = version.gsub(/\./, '\\.')
      installation_command.should == "(gem list engineyard-serverside | grep 'engineyard-serverside ' | egrep -q '#{escaped_version}[,)]') || (sudo sh -c 'cd `mktemp -d` && gem install engineyard-serverside --no-rdoc --no-ri -v #{version}')"


      installation_command.should =~ /gem list engineyard-serverside/
      installation_command.should =~ /egrep -q /
      installation_command.should =~ /gem install engineyard-serverside.*-v #{Regexp.quote serverside_version}/
    end
  end

  shared_examples_for "it accepts clean" do
    context "the --clean arg" do
      it "is present when you set clean to true" do
        adapter = described_class.new(:arguments => arguments_with(:clean => true))
        last_command(adapter).should =~ /--clean/
      end

      it "is absent when you set clean to false" do
        adapter = described_class.new(:arguments => arguments_with(:clean => false))
        last_command(adapter).should_not =~ /--clean/
      end

      it "is absent when you omit clean" do
        adapter = described_class.new(:arguments => valid_arguments)
        last_command(adapter).should_not =~ /--clean/
      end
    end
  end

  shared_examples_for "it accepts verbose" do
    context "the --verbose arg" do
      it "is present when you set verbose to true" do
        adapter = described_class.new(:arguments => arguments_with(:verbose => true))
        last_command(adapter).should =~ /--verbose/
      end

      it "is absent when you set verbose to false" do
        adapter = described_class.new(:arguments => arguments_with(:verbose => false))
        last_command(adapter).should_not =~ /--verbose/
      end

      it "is absent when you omit verbose" do
        adapter = described_class.new(:arguments => valid_arguments)
        last_command(adapter).should_not =~ /--verbose/
      end
    end
  end

  {
    :app              => '--app',
    :environment_name => '--environment-name',
    :account_name     => '--account-name',
    :stack            => '--stack',
    :framework_env    => '--framework-env',
    :ref              => '--ref',
    :git              => '--git',
    :migrate          => '--migrate',
  }.each do |arg, switch|
    shared_examples_for "it accepts #{arg}" do
      it "puts the #{switch} arg in the command line" do
        adapter = described_class.new(:arguments => arguments_with(arg => 'word'))
        last_command(adapter).should =~ /#{switch} word/
      end

      it "handles arguments that need to be escaped" do
        adapter = described_class.new(:arguments => arguments_with(arg => 'two words'))
        last_command(adapter).should =~ /#{switch} 'two words'/
      end
    end

    shared_examples_for "it treats #{arg} as optional" do
      it "omits #{switch} when you don't give it #{arg}" do
        adapter = described_class.new(:arguments => arguments_without(arg))
        last_command(adapter).should_not include(switch)
      end
    end

  end

  shared_examples_for "it treats config as optional" do
    it "omits --config when you don't give it config" do
      adapter = described_class.new(:arguments => arguments_without(:config))
      last_command(adapter).should_not include('--config')
    end
  end

  shared_examples_for "it accepts archive" do
    it "puts the --archive arg in the command line" do
      arguments = arguments_without(:git)
      arguments.archive = 'word'
      adapter = described_class.new(:arguments => arguments)
      last_command(adapter).should =~ /--archive word/
    end
  end

  shared_examples_for "it accepts serverside_version" do
    it "puts the _VERSION_ command part in the command line" do
      adapter = described_class.new(:arguments => arguments_with(:serverside_version => '1.2.3'))
      last_command(adapter).should =~ /engineyard-serverside _1.2.3_/
    end
  end

  shared_examples_for "it accepts instances" do
    context "given an unnamed instance" do
      it "puts the instance in the command line" do
        adapter = described_class.new(:arguments => arguments_with(
          :instances => [{:hostname => 'localhost', :roles => %w[han solo], :name => nil}]
        ))
        command = last_command(adapter)
        command.should =~ /--instances localhost/
        command.should =~ /--instance-roles localhost:han,solo/
        command.should_not =~ /--instance-names/
      end
    end

    context "given a named instance" do
      it "puts the instance in the command line" do
        adapter = described_class.new(:arguments => arguments_with(
          :instances => [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        ))
        command = last_command(adapter)
        command.should =~ /--instances localhost/
        command.should =~ /--instance-roles localhost:han,solo/
        command.should =~ /--instance-names localhost:chewie/
      end
    end

    context "given multiple instances" do
      it "puts the instance in the command line" do
        adapter = described_class.new(:arguments => arguments_with({
          :instances => [
            {:hostname => 'localhost', :roles => %w[wookie], :name => 'chewie'},
            {:hostname => 'crazy-ass-amazon-1243324321.domain', :roles => %w[bounty-hunter], :name => nil},
            {:hostname => 'simpler.domain', :roles => %w[pilot scruffy-lookin-nerf-herder], :name => 'han'},
          ]
        }))
        command = last_command(adapter)
        command.should =~ /--instances crazy-ass-amazon-1243324321.domain localhost simpler.domain/
        command.should =~ /--instance-roles crazy-ass-amazon-1243324321.domain:bounty-hunter localhost:wookie simpler.domain:pilot,scruffy-lookin-nerf-herder/
        command.should =~ /--instance-names localhost:chewie simpler.domain:han/
      end
    end
  end
end
