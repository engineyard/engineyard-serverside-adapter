module EY
  module Serverside
    module Adapter
      class Builder < Struct.new(:app, :framework_env, :instances, :stack, :verbose, :config)

        def app=(app)
          if app.to_s.empty?
            raise ArgumentError, "Value for 'app' must be non-empty."
          end

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
              raise ArgumentError, "Malformed instance #{instance}; it must have both [:hostname] and [:roles]"
            end
          end

          super
        end

        def stack=(stack)
          if stack.to_s.empty?
            raise ArgumentError, "Value for 'stack' must be non-empty."
          end

          super
        end

      end
    end
  end
end
  
