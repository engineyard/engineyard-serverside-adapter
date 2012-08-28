module EY
  module Serverside
    class Adapter
      class Arguments

        def self.nonempty_writer(*names)
          names.each do |name|
            define_method(:"#{name}=") do |value|
              if value.to_s.empty?
                raise ArgumentError, "Value for '#{name}' must be non-empty."
              end
              instance_variable_set("@#{name}", value)
            end
          end
        end

        attr_reader     :app, :environment_name, :account_name, :config, :framework_env, :instances, :migrate, :ref, :repo, :stack, :verbose
        nonempty_writer :app, :environment_name, :account_name, :framework_env, :ref, :repo, :stack
        attr_writer     :config, :migrate, :verbose

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

          @instances = instances
        end

      end
    end
  end
end

