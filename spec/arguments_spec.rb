require 'spec_helper'

describe EY::Serverside::Adapter::Arguments do
  def raises_argument_error(message = nil, &block)
    expect {
      block.call(described_class.new)
    }.to raise_error(ArgumentError, message)
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

  it "raises an ArgumentError immediately when serverside_version is weird" do
    raises_argument_error(/Malformed version number string what the flower/) do |arguments|
      arguments.serverside_version = 'what the flower'
    end
  end

  it "raises an ArgumentError immediately when serverside_version is empty" do
    raises_argument_error(/Value for 'serverside_version' must be non-empty/) do |arguments|
      arguments.serverside_version = nil
    end

    raises_argument_error(/Value for 'serverside_version' must be non-empty/) do |arguments|
      arguments.serverside_version = ''
    end
  end
end
