require 'pathname'
require 'engineyard-serverside-adapter/version'

module EY
  module Serverside
    class Adapter
      autoload :Action,                 'engineyard-serverside-adapter/action'
      autoload :Arguments,              'engineyard-serverside-adapter/arguments'
      autoload :Command,                'engineyard-serverside-adapter/command'
      autoload :CommandOptions,         'engineyard-serverside-adapter/command_options'

      # Backwards compatibility
      autoload :Deploy,                 'engineyard-serverside-adapter/action/deploy'
      autoload :DisableMaintenance,     'engineyard-serverside-adapter/action/disable_maintenance'
      autoload :EnableMaintenance,      'engineyard-serverside-adapter/action/enable_maintenance'
      autoload :MaintenanceStatus,      'engineyard-serverside-adapter/action/maintenance_status'
      autoload :Integrate,              'engineyard-serverside-adapter/action/integrate'
      autoload :Restart,                'engineyard-serverside-adapter/action/restart'
      autoload :Rollback,               'engineyard-serverside-adapter/action/rollback'

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

      def maintenance_status(&b)
        MaintenanceStatus.new(new_action_args, &b)
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
