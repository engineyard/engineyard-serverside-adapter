require 'escape'
require 'pathname'

module EY
  module Serverside
    class Adapter
      class Action

        def initialize(options = {}, &block)
          @gem_bin_pathname = Pathname.new(options[:gem_bin_pathname] || "")
          arguments = options[:arguments] || Arguments.new
          block.call arguments if block

          extract_state_from_arguments(arguments)
          validate!
        end

        def call(&block)
          block.call command.to_s
        end

        def verbose
          @state[:verbose]
        end

        class << self
          attr_accessor :options

          def option(name, type, extra={:required => false})
            self.options ||= {}
            options[name] = extra.merge({:type => type})
          end
        end


      private

        def extract_state_from_arguments(arguments)
          @state = self.class.options.inject({}) do |acc, (option_name, option_attrs)|
            acc.merge(option_name => arguments.send(option_name))
          end
        end

        def command
          cmd = Command.new(@gem_bin_pathname, *task)
          @state.each do |option_name, value|
            option_type = self.class.options[option_name][:type]
            switch = "--" + option_name.to_s.gsub(/_/, '-')
            cmd.send("#{option_type}_argument", switch, value)
          end
          cmd
        end

        def validate!
          self.class.options.each do |option_name, option_attrs|
            if option_attrs[:required] && !@state[option_name]
              raise ArgumentError, "Required field '#{option_name}' not provided."
            end
          end
        end

      end
    end
  end
end
