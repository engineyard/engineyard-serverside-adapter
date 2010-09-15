module EY
  module Serverside
    module Adapter
      autoload :Action,                 'engineyard-serverside-adapter/action'
      autoload :Builder,                'engineyard-serverside-adapter/builder'
      autoload :Command,                'engineyard-serverside-adapter/command'
      autoload :EnableMaintenancePage,  'engineyard-serverside-adapter/enable_maintenance_page'
      autoload :DisableMaintenancePage, 'engineyard-serverside-adapter/disable_maintenance_page'
      autoload :Integrate,              'engineyard-serverside-adapter/integrate'
      autoload :Rollback,               'engineyard-serverside-adapter/rollback'
    end
  end
end
