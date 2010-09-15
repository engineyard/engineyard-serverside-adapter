module EY
  module Serverside
    module Adapter
      class DisableMaintenancePage < Action

      private

        def task
          ['deploy', 'disable_maintenance_page']
        end

      end
    end
  end
end
