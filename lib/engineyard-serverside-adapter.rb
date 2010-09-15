module EY
  module Serverside
    class Adapter
      autoload :Action,                 'engineyard-serverside-adapter/action'
      autoload :Builder,                'engineyard-serverside-adapter/builder'
      autoload :Command,                'engineyard-serverside-adapter/command'
      autoload :Deploy,                 'engineyard-serverside-adapter/deploy'
      autoload :DisableMaintenancePage, 'engineyard-serverside-adapter/disable_maintenance_page'
      autoload :EnableMaintenancePage,  'engineyard-serverside-adapter/enable_maintenance_page'
      autoload :Integrate,              'engineyard-serverside-adapter/integrate'
      autoload :Rollback,               'engineyard-serverside-adapter/rollback'

      def initialize(engineyard_serverside_path)
        @builder = Builder.new
        yield @builder if block_given?
      end

      def deploy(&b)
        command = Deploy.new(@builder.dup, &b)
      end

      def disable_maintenance_page(&b)
        command = DisableMaintenancePage.new(@builder.dup, &b)
      end

      def enable_maintenance_page(&b)
        command = EnableMaintenancePage.new(@builder.dup, &b)
      end

      def integrate(&b)
        command = Integrate.new(@builder.dup, &b)
      end

      def rollback(&b)
        command = Rollback.new(@builder.dup, &b)
      end

    end
  end
end
