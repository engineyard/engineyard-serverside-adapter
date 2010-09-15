require 'escape'
require 'pathname'

module EY
  module Serverside
    class Adapter
      class Action

        def initialize(options = {}, &block)
          @gem_bin_path = Pathname.new(options[:gem_bin_path] || "")
          arguments = options[:arguments] || Arguments.new
          block.call arguments if block

          extract_state_from_arguments(arguments)
          validate!
        end

        def call(&block)
          block.call check_and_install_command.to_s
          block.call action_command.to_s
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

        def check_and_install_command
          "(#{check_command}) || (#{install_command})"
        end

        def check_command
          escaped_engineyard_serverside_version = ENGINEYARD_SERVERSIDE_VERSION.gsub(/\./, '\.')

          [
            Escape.shell_command([gem_path, "list", "engineyard-serverside"]),
            Escape.shell_command(["grep", "engineyard-serverside "]),
            Escape.shell_command(["egrep", "-q", "#{escaped_engineyard_serverside_version}[,)]"]),
          ].join(" | ")
        end

        def install_command
          # rubygems looks at *.gem in its current directory for
          # installation candidates, so we have to make sure it
          # runs from a directory with no gem files in it.
          #
          # rubygems help suggests that --remote will disable this
          # behavior, but it doesn't.
          install_command = "cd `mktemp -d` && #{gem_path} install engineyard-serverside --no-rdoc --no-ri -v #{ENGINEYARD_SERVERSIDE_VERSION}"
          Escape.shell_command(['sudo', 'sh', '-c', install_command])
        end

        def gem_path
          @gem_bin_path.join('gem').to_s
        end

        def action_command
          cmd = Command.new(@gem_bin_path, *task)
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
