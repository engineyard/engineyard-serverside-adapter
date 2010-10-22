module EY
  module Serverside
    class Adapter
      class Arguments < Struct.new(:app, :config, :framework_env, :instances, :migrate, :ref, :repo, :stack, :verbose)

        def app=(app)
          enforce_nonempty!('app', app)
          super
        end

        def framework_env=(framework_env)
          enforce_nonempty!('framework_env', framework_env)
          super
        end

        def instances=(instances)
          unless instances.respond_to?(:each)
            raise ArgumentError, "Value for 'instances' must look like an enumerable."
          end

          if instances.empty?
            raise ArgumentError, "Value for 'instances' must not be empty."
          end

          instances.each do |instance|
            unless instance.respond_to?(:[]) && instance[:hostname] && instance[:roles]
              raise ArgumentError, "Malformed instance #{instance.inspect}; it must have both [:hostname] and [:roles]"
            end
          end

          super
        end

        def ref=(ref)
          enforce_nonempty!('ref', ref)
          super
        end

        def repo=(repo)
          enforce_nonempty!('repo', repo)
          super
        end

        def stack=(stack)
          enforce_nonempty!('stack', stack)
          super
        end

        private

        def enforce_nonempty!(name, value)
          if value.to_s.empty?
            raise ArgumentError, "Value for '#{name}' must be non-empty."
          end
        end

      end
    end
  end
end

