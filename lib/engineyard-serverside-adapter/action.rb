require 'escape'
require 'pathname'
require 'engineyard-serverside-adapter/option'
require 'engineyard-serverside-adapter/arguments'

module EY
  module Serverside
    class Adapter
      class Action

        GEM_NAME = 'engineyard-serverside'
        BIN_NAME = GEM_NAME

        def initialize(options = {}, &block)
          @gem_bin_path = Pathname.new(options[:gem_bin_path] || "")

          @arguments           = options[:arguments]           || Arguments.new
          @serverside_gem_name = options[:serverside_gem_name] || GEM_NAME
          @serverside_bin_name = options[:serverside_bin_name] || BIN_NAME

          block.call @arguments if block

          @serverside_version = Gem::Version.create(@arguments.serverside_version || ENGINEYARD_SERVERSIDE_VERSION.dup)

          validate!
        end

        def call(&block)
          commands.each do |cmd|
            block.call cmd.to_s
          end
        end

        def commands
          @commands ||= [check_and_install_command, action_command]
        end

        def verbose
          @arguments[:verbose]
        end

        class << self
          attr_accessor :options

          def option(*args)
            self.options ||= []
            options << Option.new(*args)
          end
        end

      private

        def applicable_options
          @applicable_options ||= self.class.options.select { |option| option.on_version?(@serverside_version) }
        end

        def check_and_install_command
          "(#{check_command}) || (#{install_command})"
        end

        def check_command
          escaped_serverside_version = Regexp.escape(@serverside_version.to_s)

          [
            Escape.shell_command([gem_command_path, "list", @serverside_gem_name]),
            Escape.shell_command(["grep", "#{@serverside_gem_name} "]), # trailing space for better matching
            Escape.shell_command(["egrep", "-q", "#{escaped_serverside_version}[,)]"]),
          ].join(" | ")
        end

        def install_command
          # rubygems looks at *.gem in its current directory for
          # installation candidates, so we have to make sure it
          # runs from a directory with no gem files in it.
          #
          # rubygems help suggests that --remote will disable this
          # behavior, but it doesn't.
          install_command = "cd `mktemp -d` && #{gem_command_path} install #{@serverside_gem_name} --no-rdoc --no-ri -v #{@serverside_version}"
          Escape.shell_command(['sudo', 'sh', '-c', install_command])
        end

        def gem_command_path
          @gem_bin_path.join('gem').to_s
        end

        def serverside_command_path
          @gem_bin_path.join(@serverside_bin_name).to_s
        end

        def action_command
          Command.new(serverside_command_path, @serverside_version, *task) do |cmd|
            applicable_options.each do |option|
              cmd.send("#{option.type}_argument", option.to_switch, @arguments[option.name])
            end
          end
        end

        def validate!
          applicable_options.each do |option|
            if option.required? && !@arguments[option.name]
              raise ArgumentError, "Required field '#{option.name}' not provided."
            end
          end
        end

      end
    end
  end
end
