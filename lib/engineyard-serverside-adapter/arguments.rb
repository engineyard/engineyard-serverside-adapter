module EY
  module Serverside
    class Adapter

      # A mutable arguments receiver that fails fast when bad values are given.
      class Arguments

        def self.nonempty_attr_accessor(*names)
          attr_reader *names

          names.each do |name|
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

        attr_accessor :clean, :config, :migrate, :serverside_version, :verbose, :ignore_existing

        attr_reader :instance_names, :instance_roles, :instances
        alias repo git # for versions where --repo is required, it is accessed via this alias

        def [](key)
          send(key)
        end

        # This is a special setter for setting all instance information at the same time.
        # It sets @instance_roles, @instance_names and @instances.
        def instances=(instances)
          unless instances.respond_to?(:each)
            raise ArgumentError, "Value for 'instances' must look like an enumerable."
          end

          if instances.empty?
            raise ArgumentError, "Value for 'instances' must not be empty."
          end

          @instance_roles = instances.inject({}) do |roles, instance|
            unless instance.respond_to?(:[]) && instance[:hostname] && instance[:roles]
              raise ArgumentError, "Malformed instance #{instance.inspect}; it must have both [:hostname] and [:roles]"
            end

            roles.merge(instance[:hostname] => instance[:roles].join(','))
          end

          @instance_names = instances.inject({}) do |names, instance|
            names.merge(instance[:hostname] => instance[:name])
          end

          @instances = instances.map{|i| i[:hostname]}
        end

        # Uses Gem::Version to validate the version arg.
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

