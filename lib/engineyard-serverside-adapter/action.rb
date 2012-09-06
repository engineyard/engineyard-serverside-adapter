require 'escape'
require 'pathname'
require 'engineyard-serverside-adapter/option'
require 'engineyard-serverside-adapter/arguments'

module EY
  module Serverside
    class Adapter
      class Action

        def initialize(options = {}, &block)
          @gem_bin_path = Pathname.new(options[:gem_bin_path] || "")
          @arguments = options[:arguments] || Arguments.new
          block.call @arguments if block
          @serverside_version = @arguments[:serverside_version]
          @serverside_version ||= Gem::Version.create(ENGINEYARD_SERVERSIDE_VERSION.dup)
          validate!
        end

        def call(&block)
          block.call check_and_install_command.to_s
          block.call action_command.to_s
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
          escaped_serverside_version = @serverside_version.to_s.gsub(/\./, '\.')

          [
            Escape.shell_command([gem_path, "list", "engineyard-serverside"]),
            Escape.shell_command(["grep", "engineyard-serverside "]),
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
          install_command = "cd `mktemp -d` && #{gem_path} install engineyard-serverside --no-rdoc --no-ri -v #{@serverside_version}"
          Escape.shell_command(['sudo', 'sh', '-c', install_command])
        end

        def gem_path
          @gem_bin_path.join('gem').to_s
        end

        def action_command
          cmd = Command.new(@gem_bin_path, @serverside_version, *task)
          applicable_options.each do |option|
            cmd.send("#{option.type}_argument", option.to_switch, @arguments[option.name])
          end
          cmd
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
