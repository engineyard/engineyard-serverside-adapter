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

  shared_examples_for "it accepts verbose" do
    context "the --verbose arg" do
      it "is present when you set verbose to true" do
        adapter = described_class.new(:arguments => arguments_with(:verbose => true))
        adapter.call {|cmd| cmd.should =~ /--verbose/}
      end

      it "is absent when you set verbose to false" do
        adapter = described_class.new(:arguments => arguments_with(:verbose => false))
        adapter.call {|cmd| cmd.should_not =~ /--verbose/}
      end

      it "is absent when you omit verbose" do
        adapter = described_class.new(:arguments => valid_arguments)
        adapter.call {|cmd| cmd.should_not =~ /--verbose/}
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
        adapter.call {|cmd| cmd.should =~ /#{switch} word/}
      end

      it "handles arguments that need to be escaped" do
        adapter = described_class.new(:arguments => arguments_with(arg => 'two words'))
        adapter.call {|cmd| cmd.should =~ /#{switch} 'two words'/}
      end
    end

    shared_examples_for "it treats #{arg} as optional" do
      it "omits #{switch} when you don't give it #{arg}" do
        adapter = described_class.new(:arguments => arguments_without(arg))
        adapter.call {|cmd| cmd.should_not include(switch)}
      end
    end

  end

  shared_examples_for "it treats config as optional" do
    it "omits --config when you don't give it config" do
      adapter = described_class.new(:arguments => arguments_without(:config))
      adapter.call {|cmd| cmd.should_not include('--config')}
    end
  end

  shared_examples_for "it accepts instances" do
    context "given an unnamed instance" do
      it "puts the instance in the command line" do
        adapter = described_class.new(:arguments => arguments_with(
          :instances => [{:hostname => 'localhost', :roles => %w[han solo], :name => nil}]
        ))
        adapter.call do |command|
          command.should =~ /--instances localhost/
          command.should =~ /--instance-roles localhost:han,solo/
          command.should_not =~ /--instance-names/
        end
      end
    end

    context "given a named instance" do
      it "puts the instance in the command line" do
        adapter = described_class.new(:arguments => arguments_with(
          :instances => [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        ))
        adapter.call do |command|
          command.should =~ /--instances localhost/
          command.should =~ /--instance-roles localhost:han,solo/
          command.should =~ /--instance-names localhost:chewie/
        end
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
        adapter.call do |command|
          command.should =~ /--instances crazy-ass-amazon-1243324321.domain localhost simpler.domain/
          command.should =~ /--instance-roles crazy-ass-amazon-1243324321.domain:bounty-hunter localhost:wookie simpler.domain:pilot,scruffy-lookin-nerf-herder/
          command.should =~ /--instance-names localhost:chewie simpler.domain:han/
        end
      end
    end
  end
end
