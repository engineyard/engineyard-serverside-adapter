require 'rubygems'
require 'bundler/setup'

require 'engineyard-serverside-adapter'
require 'pp'

module BuilderHelpers
  def valid_options
    {
      :app           => 'rackapp',
      :framework_env => 'production',
      :instances     => [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}],
      :stack         => 'nginx_unicorn',
    }
  end

  def valid_builder() builder_without() end   # without nothing --> valid :)

  def builder_with(fields)
    builder = valid_builder
    fields.each do |field, value|
      builder.send("#{field}=", value)
    end
    builder
  end

  def builder_without(*fields)
    builder = EY::Serverside::Adapter::Builder.new
    valid_options.each do |field, value|
      builder.send("#{field}=", value) unless fields.include?(field)
    end
    builder
  end
end

module RequiredFieldHelpers
  def it_should_require(field)
    context "field #{field}" do
      it "is just fine when #{field} is there" do
        lambda { described_class.new(valid_builder) }.should_not raise_error
      end

      it "raises an error if #{field} is missing" do
        lambda { described_class.new(builder_without(field)) }.should raise_error(ArgumentError)
      end
    end
  end
end


Spec::Runner.configure do |config|
  config.include BuilderHelpers
  config.extend RequiredFieldHelpers

  shared_examples_for "it accepts verbose" do
    context "the --verbose arg" do
      it "is present when you set verbose to true" do
        adapter = described_class.new(builder_with(:verbose => true))
        adapter.call {|cmd| cmd.should =~ /--verbose/}
      end

      it "is absent when you set verbose to false" do
        adapter = described_class.new(builder_with(:verbose => false))
        adapter.call {|cmd| cmd.should_not =~ /--verbose/}
      end

      it "is absent when you omit verbose" do
        adapter = described_class.new(valid_builder)
        adapter.call {|cmd| cmd.should_not =~ /--verbose/}
      end
    end
  end
end
