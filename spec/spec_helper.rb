require 'rubygems'
require 'bundler/setup'

require 'engineyard-serverside-adapter'
require 'pp'

module ArgumentsHelpers
  def valid_options
    {
      :app           => 'rackapp',
      :framework_env => 'production',
      :instances     => [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}],
      :ref           => 'master',
      :repo          => 'git@github.com:engineyard/engineyard-serverside.git',
      :stack         => 'nginx_unicorn',
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
    commands = []
    adapter.call { |command| commands << command }
    commands
  end

  def last_command(adapter)
    all_commands(adapter).last
  end
end

module RequiredFieldHelpers
  def it_should_require(field)
    context "field #{field}" do
      it "is just fine when #{field} is there" do
        lambda { described_class.new(:arguments => valid_arguments) }.should_not raise_error
      end

      it "raises an error if #{field} is missing" do
        lambda { described_class.new(:arguments => arguments_without(field)) }.should raise_error(ArgumentError)
      end
    end
  end
end

Spec::Runner.configure do |config|
  config.include ArgumentsHelpers
  config.extend RequiredFieldHelpers

  shared_examples_for "it installs engineyard-serverside" do
    it "checks for and installs engineyard-serverside before invoking it" do
      adapter = described_class.new(:arguments => valid_arguments)

      all_commands(adapter).size.should == 2
      installation_command = all_commands(adapter).first

      # of course, the only way to be sure is to actually run it, but
      # this gives us regression-proofing
      version = EY::Serverside::Adapter::ENGINEYARD_SERVERSIDE_VERSION
      escaped_version = version.gsub(/\./, '\\.')
      installation_command.should == "(gem list engineyard-serverside | grep 'engineyard-serverside ' | egrep -q '#{escaped_version}[,)]') || (sudo sh -c 'cd `mktemp -d` && gem install engineyard-serverside --no-rdoc --no-ri -v #{version}')"


      installation_command.should =~ /gem list engineyard-serverside/
      installation_command.should =~ /egrep -q /
      installation_command.should =~ /gem install engineyard-serverside.*-v #{Regexp.quote EY::Serverside::Adapter::ENGINEYARD_SERVERSIDE_VERSION}/
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
    :app           => '--app',
    :stack         => '--stack',
    :framework_env => '--framework-env',
    :ref           => '--ref',
    :repo          => '--repo',
    :migrate       => '--migrate',
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
