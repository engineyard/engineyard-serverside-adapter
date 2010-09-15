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
      autoload :Rollback,               'engineyard-serverside-adapter/rollback'

      def initialize(gem_bin_path = "")
        @gem_bin_pathname = Pathname.new(gem_bin_path)
        @arguments = Arguments.new
        yield @arguments if block_given?
      end

      def deploy(&b)
        command = Deploy.new(:arguments => @arguments.dup, :gem_bin_pathname => @gem_bin_pathname, &b)
      end

      def disable_maintenance_page(&b)
        command = DisableMaintenancePage.new(:arguments => @arguments.dup, :gem_bin_pathname => @gem_bin_pathname, &b)
      end

      def enable_maintenance_page(&b)
        command = EnableMaintenancePage.new(:arguments => @arguments.dup, :gem_bin_pathname => @gem_bin_pathname, &b)
      end

      def integrate(&b)
        command = Integrate.new(:arguments => @arguments.dup, :gem_bin_pathname => @gem_bin_pathname, &b)
      end

      def rollback(&b)
        command = Rollback.new(:arguments => @arguments.dup, :gem_bin_pathname => @gem_bin_pathname, &b)
      end

    end
  end
end
