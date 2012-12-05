require 'escape'
require 'multi_json'

module EY
  module Serverside
    class Adapter
      class Command
        def initialize(binary_path, version, *task)
          @binary    = binary_path.to_s
          @version   = version
          @task      = task
          @arguments = []

          yield self if block_given?
        end

        def to_s
          Escape.shell_command [@binary, "_#{@version}_"] + @task + @arguments.sort_by { |x| x.first }.flatten
        end

        def array_argument(switch, values)
          compacted = values.compact.sort
          if compacted.any?
            @arguments << [switch, compacted]
          end
        end

        def boolean_argument(switch, value)
          if value
            @arguments << [switch]
          end
        end

        def hash_argument(switch, pairs)
          if pairs.any? {|k,v| !v.nil?}
            @arguments << [switch, pairs.reject { |k,v| v.nil? }.map { |pair| pair.join(':') }.sort]
          end
        end

        def instances_argument(_, instances)
          role_pairs = instances.inject({}) do |roles, instance|
            roles.merge(instance[:hostname] => instance[:roles].join(','))
          end
          hash_argument('--instance-roles', role_pairs)

          role_pairs = instances.inject({}) do |roles, instance|
            roles.merge(instance[:hostname] => instance[:name])
          end
          hash_argument('--instance-names', role_pairs)

          array_argument('--instances', instances.map{|i| i[:hostname]})
        end

        def json_argument(switch, value)
          if value
            string_argument(switch, MultiJson.dump(value))
          end
        end

        def string_argument(switch, value)
          if !value
            @arguments << [switch.sub(/^--/,'--no-')] # specifically for no-migrate
          elsif !value.to_s.empty?
            @arguments << [switch, value]
          end
        end

      end
    end
  end
end
