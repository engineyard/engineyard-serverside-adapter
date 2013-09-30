module EY
  module Serverside
    class Adapter
      class Arguments

        def self.nonempty_attr_accessor(*names)
          names.each do |name|
            define_method(name) do
              instance_variable_get("@#{name}")
            end

            define_method(:"#{name}=") do |value|
              if value.nil? || value.to_s.empty?
                raise ArgumentError, "Value for '#{name}' must be non-empty."
              end
              instance_variable_set("@#{name}", value)
            end
          end
        end

        nonempty_attr_accessor :app, :account_name, :archive, :environment_name
        nonempty_attr_accessor :framework_env, :git, :ref, :stack
        attr_accessor :clean, :config, :migrate, :serverside_version, :verbose
        attr_reader :instances
        alias repo git # for versions where --repo is required, it is accessed via this alias

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

        def serverside_version=(value)
          if value.nil? || value.to_s.empty?
            raise ArgumentError, "Value for 'serverside_version' must be non-empty."
          end
          @serverside_version = Gem::Version.create(value.dup) # dup b/c Gem::Version sometimes modifies its argument :(
        end

      end
    end
  end
end

