require 'spec_helper'

describe EY::Serverside::Adapter::Arguments do
  def raises_argument_error(message = nil, &block)
    lambda {
      block.call(described_class.new)
    }.should raise_error(ArgumentError, message)
  end

  it "raises an ArgumentError immediately when instances is empty" do
    raises_argument_error do |arguments|
      arguments.instances = []
    end
  end

  it "raises an ArgumentError immediately when instances is something totally silly" do
    raises_argument_error do |arguments|
      arguments.instances = 42
    end
  end

  it "raises an ArgumentError immediately when instances contains something totally silly" do
    raises_argument_error(/Malformed instance nil/) do |arguments|
      arguments.instances = [nil]
    end
  end

end
