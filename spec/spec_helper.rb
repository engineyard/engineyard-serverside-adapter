require 'rubygems'
require 'bundler/setup'

require 'engineyard-serverside-adapter'
require 'pp'

module RequiredFieldHelpers
  def it_should_require(field)
    context "field #{field}" do
      before(:each) do
        # everything required is here
        @valid_options = {
          :app => 'rackapp',
          :stack => 'nginx_unicorn',
          :instances => [{:hostname => 'localhost', :roles => %w[han solo], :name => 'chewie'}]
        }
      end

      def valid_builder() builder_without() end   # without nothing --> valid :)

      def builder_without(*fields)
        builder = EY::Serverside::Adapter::Builder.new
        @valid_options.each do |field, value|
          builder.send("#{field}=", value) unless fields.include?(field)
        end
        builder
      end

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
  config.extend RequiredFieldHelpers
end
