module EY
  module Serverside
    class Adapter
      class Arguments

        def self.nonempty_writer(*names)
          names.each do |name|
            define_method(:"#{name}=") do |value|
              if value.nil? || value.to_s.empty?
                raise ArgumentError, "Value for '#{name}' must be non-empty."
              end
              self[name] = value
            end
          end
        end

        def self.writer(*names)
          names.each do |name|
            define_method(:"#{name}=") do |value|
              self[name] = value
            end
          end
        end

        nonempty_writer :app, :environment_name, :account_name, :framework_env, :ref, :repo, :serverside_version, :stack
        writer :config, :migrate, :verbose

        def initialize(data={})
          @data = data
        end

        def dup
          self.class.new(@data.dup)
        end

        def []=(key, val)
          @data[key.to_sym] = val
        end

        def [](key)
          @data[key.to_sym]
        end

        def key?(key)
          @data.key?(key.to_sym)
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

          self[:instances] = instances
        end

        def serverside_version=(value)
          self[:serverside_version] = Gem::Version.create(value.dup) # dup b/c Gem::Version sometimes modifies its argument :(
        end

        def method_missing(meth, *)
          key?(meth) ? self[meth] : super
        end

      end
    end
  end
end

