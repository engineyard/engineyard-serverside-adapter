require 'pathname'

module EY
  module Serverside
    class Adapter
      require 'engineyard-serverside-adapter/version'
      autoload :Action,                 'engineyard-serverside-adapter/action'
      autoload :Arguments,              'engineyard-serverside-adapter/arguments'
      autoload :Command,                'engineyard-serverside-adapter/command'
      autoload :Deploy,                 'engineyard-serverside-adapter/deploy'
      autoload :DisableMaintenance,     'engineyard-serverside-adapter/disable_maintenance'
      autoload :EnableMaintenance,      'engineyard-serverside-adapter/enable_maintenance'
      autoload :Integrate,              'engineyard-serverside-adapter/integrate'
      autoload :Restart,                'engineyard-serverside-adapter/restart'
      autoload :Rollback,               'engineyard-serverside-adapter/rollback'

      def initialize(gem_bin_path = "", &block)
        @gem_bin_path = Pathname.new(gem_bin_path)
        @arguments    = Arguments.new

        block.call(@arguments) if block
      end

      def deploy(&b)
        Deploy.new(new_action_args, &b)
      end

      def disable_maintenance(&b)
        DisableMaintenance.new(new_action_args, &b)
      end

      def enable_maintenance(&b)
        EnableMaintenance.new(new_action_args, &b)
      end

      def integrate(&b)
        Integrate.new(new_action_args, &b)
      end

      def restart(&b)
        Restart.new(new_action_args, &b)
      end

      def rollback(&b)
        Rollback.new(new_action_args, &b)
      end

      private

      def new_action_args
        {:arguments => @arguments.dup, :gem_bin_path => @gem_bin_path}
      end

    end
  end
end
