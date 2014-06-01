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

        def to_argv
          [@binary, "_#{@version}_"] + @task + @arguments.sort_by { |x| x.first }.flatten
        end

        def to_s
          Escape.shell_command to_argv
        end

        def argument(type, switch, value)
          send(:"#{type}_argument", switch, value)
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
