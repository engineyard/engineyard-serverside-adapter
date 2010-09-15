require 'spec_helper'

describe EY::Serverside::Adapter::Rollback do
  context "with valid arguments" do

    let(:command) do
      adapter = described_class.new do |builder|
        builder.app = "rackapp"
        builder.instances = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        builder.stack = "nginx_unicorn"
      end
      adapter.call {|cmd| cmd}
    end

    it "invokes the correct version of engineyard-serverside" do
      command.should =~ /engineyard-serverside _#{EY::Serverside::Adapter::VERSION}_/
    end

    it "puts the app in the command line" do
      command.should =~ /--app rackapp/
    end

    it "puts the instances in the command line" do
      command.should =~ /--instances localhost/
      command.should =~ /--instance-roles localhost:han,solo/
      command.should =~ /--instance-names localhost:chewie/
    end

    it "puts the stack in the command line" do
      command.should =~ /--stack nginx_unicorn/
    end

    it "properly quotes odd arguments just in case" do
      adapter = described_class.new do |builder|
        builder.app = "rack app"
        builder.instances = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        builder.stack = 'nginx_unicorn'
      end
      adapter.call {|cmd| cmd.should =~ /--app 'rack app'/}
    end

    it "invokes the right deploy subcommand" do
      command.should =~ /engineyard-serverside _#{EY::Serverside::Adapter::VERSION}_ deploy rollback/
    end

    it "invokes exactly the right command" do
      command.should == "engineyard-serverside _#{EY::Serverside::Adapter::VERSION}_ deploy rollback --app rackapp --instances localhost --instance-roles localhost:han,solo --instance-names localhost:chewie --stack nginx_unicorn"
    end
  end

  context "the --verbose arg" do
    it "is present when you set verbose to true" do
      adapter = described_class.new do |builder|
        builder.app = 'myapp'
        builder.instances = [{:hostname => 'dontcare', :roles => []}]
        builder.stack = 'nginx_unicorn'
        builder.verbose = true
      end

      adapter.call {|cmd| cmd.should =~ /--verbose/}
    end

    it "is absent when you set verbose to false" do
      adapter = described_class.new do |builder|
        builder.app = 'myapp'
        builder.instances = [{:hostname => 'dontcare', :roles => []}]
        builder.stack = 'nginx_unicorn'
        builder.verbose = false
      end

      adapter.call {|cmd| cmd.should_not =~ /--verbose/}
    end

    it "is absent when you omit verbose" do
      adapter = described_class.new do |builder|
        builder.app = 'myapp'
        builder.instances = [{:hostname => 'dontcare', :roles => []}]
        builder.stack = 'nginx_unicorn'
      end

      adapter.call {|cmd| cmd.should_not =~ /--verbose/}
    end
  end

  context "with missing arguments" do
    def raises_argument_error(&block)
      lambda {
        described_class.new(&block)
      }.should raise_error(ArgumentError)
    end

    it_should_require :app
    it_should_require :stack
    it_should_require :instances

    it "raises an ArgumentError immediately when stack is blank" do
      raises_argument_error do |builder|
        builder.app = 'random-string'
        builder.instances = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        builder.stack = ''
      end
    end

    it "raises an ArgumentError immediately when instances is empty" do
      raises_argument_error do |builder|
        builder.app = "rackapp"
        builder.instances = []
        builder.stack = 'nginx_unicorn'
      end
    end

    it "raises an ArgumentError immediately when instances is something totally silly" do
      raises_argument_error do |builder|
        builder.app = "rackapp"
        builder.instances = 42
        builder.stack = 'nginx_unicorn'
      end
    end

    it "raises an ArgumentError immediately when instances contains something totally silly" do
      raises_argument_error do |builder|
        builder.app = "rackapp"
        builder.instances = [nil]
        builder.stack = 'nginx_unicorn'
      end
    end

  end
end
