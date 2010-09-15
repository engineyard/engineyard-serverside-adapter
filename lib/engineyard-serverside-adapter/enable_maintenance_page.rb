module EY
  module Serverside
    class Adapter
      class EnableMaintenancePage < Action

        option :app,       :string,    :required => true
        option :instances, :instances, :required => true
        option :verbose,   :boolean

      private

        def task
          ['deploy', 'enable_maintenance_page']
        end

      end
    end
  end
end
