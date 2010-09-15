module EY
  module Serverside
    module Adapter
      class DisableMaintenancePage < Action

        option :app,       :string,    :required => true
        option :instances, :instances, :required => true
        option :verbose,   :boolean

      private

        def task
          ['deploy', 'disable_maintenance_page']
        end

      end
    end
  end
end
