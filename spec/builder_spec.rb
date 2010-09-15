require 'spec_helper'

describe EY::Serverside::Adapter::Builder do
  def raises_argument_error(&block)
    lambda {
      block.call(described_class.new)
    }.should raise_error(ArgumentError)
  end

  it "raises an ArgumentError immediately when instances is empty" do
    raises_argument_error do |builder|
      builder.instances = []
    end
  end

  it "raises an ArgumentError immediately when instances is something totally silly" do
    raises_argument_error do |builder|
      builder.instances = 42
    end
  end

  it "raises an ArgumentError immediately when instances contains something totally silly" do
    raises_argument_error do |builder|
      builder.instances = [nil]
    end
  end

end
