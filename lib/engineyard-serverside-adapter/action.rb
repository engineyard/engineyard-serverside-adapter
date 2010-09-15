require 'escape'

module EY
  module Serverside
    module Adapter
      class Action

        def initialize(builder = nil, &block)
          builder ||= begin
                        b = Builder.new
                        block.call b
                        b
                      end

          extract_state_from_builder(builder)
          validate!
        end

        def call(&block)
          block.call command.to_s
        end

      private

        def extract_state_from_builder(builder)
          @instances = builder.instances
          @app       = builder.app
          @verbose   = builder.verbose
        end

        def command
          cmd = Command.new(*task)
          cmd.string_argument    '--app', @app
          cmd.instances_argument @instances
          cmd.boolean_argument   '--verbose', @verbose
          cmd
        end

        def validate!
          unless @instances
            raise ArgumentError, "Required field 'instances' not provided."
          end

          unless @app
            raise ArgumentError, "Required field 'app' not provided."
          end
        end

      end
    end
  end
end
