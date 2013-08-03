module EY
  module Serverside
    class Adapter
      class Option
        attr_reader :name, :type

        def initialize(name, type, options={:required => false})
          @name, @type = name, type
          @version_requirement = Gem::Requirement.create(options[:version]) if options[:version]
          @options = options
        end

        def to_switch
          "--#{@name}".gsub(/_/, '-')
        end

        def on_version?(serverside_version)
          !@version_requirement or @version_requirement.satisfied_by?(serverside_version)
        end

        # Check if the option should always be included.
        #
        # Returns a boolean.
        def include?
          @options[:include]
        end

        def required_on_version?(serverside_version)
          case @options[:required]
          when true
            true
          when String
            requirement = Gem::Requirement.create(@options[:required])
            requirement.satisfied_by?(serverside_version)
          end
        end

      end
    end
  end
end
