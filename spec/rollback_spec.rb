require 'spec_helper'

describe EY::Serverside::Adapter::Rollback do
  it_should_behave_like "it accepts verbose"

  context "with valid arguments" do

    let(:command) do
      adapter = described_class.new do |builder|
        builder.app = "rackapp"
        builder.instances = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        builder.stack = "nginx_unicorn"
        builder.config = {'a' => 1}
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

    it "puts the config in the command line as json" do
      command.should =~ /--config '#{Regexp.quote '{"a":1}'}'/
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
      command.should == "engineyard-serverside _#{EY::Serverside::Adapter::VERSION}_ deploy rollback --app rackapp --config '{\"a\":1}' --instance-names localhost:chewie --instance-roles localhost:han,solo --instances localhost --stack nginx_unicorn"
    end
  end

  context "with missing arguments" do
    it_should_require :app
    it_should_require :stack
    it_should_require :instances
  end
end
