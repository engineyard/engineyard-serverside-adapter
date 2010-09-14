require 'escape'
require 'ostruct'

module EY
  module Serverside
    module Adapter
      class EnableMaintenancePage

        class Builder < Struct.new(:app, :instances, :verbose)
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
        end

        def initialize(&block)
          builder = Builder.new
          block.call builder

          @instances = builder.instances
          @app       = builder.app
          @verbose   = builder.verbose
          validate!
        end

        def call(&block)
          block.call command_str
        end

      private

        def command_str
          Escape.shell_command [
            'engineyard-serverside',
            "_#{VERSION}_",
            'deploy', 'enable_maintenance_page',
            '--app', @app,
          ] + instances_arg + instance_roles_arg + instance_names_arg + verbose_arg
        end

        def verbose_arg
          @verbose ? ['--verbose'] : []
        end

        def instances_arg
          array_argument('--instances', @instances.map{|i| i[:hostname]})
        end

        def instance_roles_arg
          role_pairs = @instances.inject({}) do |roles, instance|
            roles.merge(instance[:hostname] => instance[:roles].join(','))
          end
          hash_argument('--instance-roles', role_pairs)
        end

        def instance_names_arg
          role_pairs = @instances.inject({}) do |roles, instance|
            roles.merge(instance[:hostname] => instance[:name])
          end
          hash_argument('--instance-names', role_pairs)
        end

        def array_argument(switch, values)
          compacted = values.compact.sort
          if compacted.any?
            [switch] + values
          else
            []
          end
        end

        def hash_argument(switch, pairs)
          if pairs.any? {|k,v| !v.nil?}
            [switch] + pairs.reject { |k,v| v.nil? }.map { |pair| pair.join(':') }.sort
          else
            []
          end
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
