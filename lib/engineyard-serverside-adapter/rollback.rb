module EY
  module Serverside
    module Adapter
      class Rollback < Action


      private

        def task
          ['deploy', 'rollback']
        end

        def extract_state_from_builder(builder)
          super
          @stack  = builder.stack
          @config = builder.config
        end

        def command
          cmd = super
          cmd.string_argument '--stack',  @stack
          cmd.json_argument   '--config', @config
          cmd
        end

        def validate!
          super
          unless @stack
            raise ArgumentError, "Required field 'stack' not provided."
          end
        end

      end
    end
  end
end
