require 'spec_helper'

describe EY::Serverside::Adapter::Rollback do
  it_should_behave_like "it accepts app"
  it_should_behave_like "it accepts instances"
  it_should_behave_like "it accepts stack"
  it_should_behave_like "it accepts verbose"

  it_should_require :app
  it_should_require :stack
  it_should_require :instances

  context "with valid arguments" do
    let(:command) do
      adapter = described_class.new do |arguments|
        arguments.app = "rackapp"
        arguments.instances = [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        arguments.stack = "nginx_unicorn"
        arguments.config = {'a' => 1}
      end
      adapter.call {|cmd| cmd}
    end

    it "puts the config in the command line as json" do
      command.should =~ /--config '#{Regexp.quote '{"a":1}'}'/
    end

    it "invokes exactly the right command" do
      command.should == "engineyard-serverside _#{EY::Serverside::Adapter::VERSION}_ deploy rollback --app rackapp --config '{\"a\":1}' --instance-names localhost:chewie --instance-roles localhost:han,solo --instances localhost --stack nginx_unicorn"
    end
  end
end
