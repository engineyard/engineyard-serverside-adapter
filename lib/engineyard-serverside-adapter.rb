require 'pathname'

module EY
  module Serverside
    class Adapter
      autoload :Action,                 'engineyard-serverside-adapter/action'
      autoload :Arguments,              'engineyard-serverside-adapter/arguments'
      autoload :Command,                'engineyard-serverside-adapter/command'
      autoload :Deploy,                 'engineyard-serverside-adapter/deploy'
      autoload :DisableMaintenancePage, 'engineyard-serverside-adapter/disable_maintenance_page'
      autoload :EnableMaintenancePage,  'engineyard-serverside-adapter/enable_maintenance_page'
      autoload :Integrate,              'engineyard-serverside-adapter/integrate'
      autoload :Restart,                'engineyard-serverside-adapter/restart'
      autoload :Rollback,               'engineyard-serverside-adapter/rollback'
      autoload :VERSION,                'engineyard-serverside-adapter/version'

      # engineyard-serverside uses major.minor.patch; using a
      # potentially-4-digit version lets us release fixes in the
      # adapter while still keeping in version sync
      ENGINEYARD_SERVERSIDE_VERSION = ENV['ENGINEYARD_SERVERSIDE_VERSION'] || VERSION.split('.')[0..2].join('.')

      def initialize(gem_bin_path = "")
        @gem_bin_path = Pathname.new(gem_bin_path)
        @arguments    = Arguments.new

        yield @arguments if block_given?
      end

      def deploy(&b)
        Deploy.new(new_action_args, &b)
      end

      def disable_maintenance_page(&b)
        DisableMaintenancePage.new(new_action_args, &b)
      end

      def enable_maintenance_page(&b)
        EnableMaintenancePage.new(new_action_args, &b)
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
