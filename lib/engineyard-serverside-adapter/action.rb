require 'escape'
require 'pathname'
require 'engineyard-serverside-adapter/option'
require 'engineyard-serverside-adapter/arguments'

module EY
  module Serverside
    class Adapter
      class Action

        class << self
          attr_accessor :options

          def option(*args)
            self.options ||= []
            options << Option.new(*args)
          end
        end

        GEM_NAME = 'engineyard-serverside'
        BIN_NAME = GEM_NAME

        def initialize(options = {}, &block)
          @gem_bin_path = Pathname.new(options[:gem_bin_path] || "")

          @arguments           = options[:arguments]           || Arguments.new
          @serverside_gem_name = options[:serverside_gem_name] || GEM_NAME
          @serverside_bin_name = options[:serverside_bin_name] || BIN_NAME

          block.call @arguments if block

          @serverside_version = @arguments.serverside_version

          validate!
        end

        def call(&block)
          commands.all? { |cmd| block.call(cmd.to_s) }
        end

        def commands
          @commands ||= [check_and_install_command, action_command]
        end

        def verbose
          @arguments.verbose
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

        # Initialize a command from arguments.
        #
        # Returns an instance of Command.
        def action_command
          Command.new(serverside_command_path, @serverside_version, *task) do |cmd|
            given_applicable_options = given_options & applicable_options
            given_applicable_options.each do |option|
              cmd.send("#{option.type}_argument", option.to_switch, @arguments.send(option.name))
            end
          end
        end

        # only options with a value or with `:include` are used as command flags.
        #
        # This is not constrained to applicable options because we need to
        # error if there are duplicate options given even if the version does
        # not support those options.
        #
        # Primarily, this is for :git and :archive. If both are given for a
        # version that doesn't support it, it's still an error. We don't want
        # to exclude archive from a older version and then perform a git
        # deploy, which really we should have errored for receiving both.
        def given_options
          @given_options ||= self.class.options.select do |option|
            @arguments.send(option.name) || option.include?
          end
        end

        def required_options
          applicable_options.select do |option|
            option.required_on_version?(@serverside_version)
          end
        end

        def validate!
          unless @serverside_version
            raise ArgumentError, "Required field [serverside_version] not provided."
          end

          missing = required_options - given_options
          unless missing.empty?
            options_s = missing.map{|option| option.name}.join(', ')
            raise ArgumentError, "Required fields [#{options_s}] not provided."
          end
        end

      end
    end
  end
end
