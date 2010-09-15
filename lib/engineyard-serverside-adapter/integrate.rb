module EY
  module Serverside
    module Adapter
      class Integrate < Action


      private

        def task
          ['integrate']
        end

        def extract_state_from_builder(builder)
          super
          @stack = builder.stack
          @framework_env = builder.framework_env
        end

        def command
          cmd = super
          cmd.string_argument '--stack', @stack
          cmd.string_argument '--framework-env', @framework_env
          cmd
        end

        def validate!
          super
          unless @stack
            raise ArgumentError, "Required field 'stack' not provided."
          end

          unless @framework_env
            raise ArgumentError, "Required field 'framework_env' not provided."
          end
        end

      end
    end
  end
end
