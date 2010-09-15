module EY
  module Serverside
    module Adapter
      class Deploy < Action


      private

        def task
          ['deploy']
        end

        def extract_state_from_builder(builder)
          super
          @config        = builder.config
          @framework_env = builder.framework_env
          @migrate       = builder.migrate
          @ref           = builder.ref
          @repo          = builder.repo
          @stack         = builder.stack
        end

        def command
          cmd = super
          cmd.json_argument   '--config',         @config
          cmd.string_argument '--framework-env',  @framework_env
          cmd.string_argument '--migrate',        @migrate
          cmd.string_argument '--ref',            @ref
          cmd.string_argument '--repo',           @repo
          cmd.string_argument '--stack',          @stack
          cmd
        end

        def validate!
          super

          unless @framework_env
            raise ArgumentError, "Required field 'framework_env' not provided."
          end

          unless @ref
            raise ArgumentError, "Required field 'ref' not provided."
          end

          unless @repo
            raise ArgumentError, "Required field 'repo' not provided."
          end

          unless @stack
            raise ArgumentError, "Required field 'stack' not provided."
          end
        end

      end
    end
  end
end
