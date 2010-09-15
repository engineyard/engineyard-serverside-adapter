module EY
  module Serverside
    module Adapter
      autoload :Action,                 'engineyard-serverside-adapter/action'
      autoload :Builder,                'engineyard-serverside-adapter/builder'
      autoload :Command,                'engineyard-serverside-adapter/command'
      autoload :EnableMaintenancePage,  'engineyard-serverside-adapter/enable_maintenance_page'
      autoload :DisableMaintenancePage, 'engineyard-serverside-adapter/disable_maintenance_page'
      autoload :Rollback,               'engineyard-serverside-adapter/rollback'
    end
  end
end
