class EY::Serverside::Adapter::CommandOptions
  module ClassMethods
    def command_options
      @options ||= EY::Serverside::Adapter::CommandOptions.new
    end

    def option(*args)
      command_options.add(*args)
    end
  end

  attr_accessor :options

  def initialize
    self.options = []
  end

  def add(*args)
    option = EY::Serverside::Adapter::Option.new(*args)
    self.options << option
    option
  end

  def applicable(version)
    select { |option| option.on_version?(version) }
  end

  def required(version)
    select { |option| option.required_on_version?(version) }
  end

  def select(&block)
    self.options.select(&block)
  end

end
