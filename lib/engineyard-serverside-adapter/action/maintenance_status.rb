module EY::Serverside
  class Adapter
    class Action
      class MaintenanceStatus < Action

        version_requirement '>=2.5.0'

        option :app,              :string,    :required => true
        option :account_name,     :string,    :required => true
        option :config,           :json
        option :environment_name, :string,    :required => true
        option :instance_names,   :hash,      :required => true
        option :instance_roles,   :hash,      :required => true
        option :instances,        :array,     :required => true
        option :verbose,          :boolean

      private

        def task
          ['maintenance_status']
        end

      end

      # backwards compatibility
      EY::Serverside::Adapter::MaintenanceStatus = MaintenanceStatus
    end
  end
end
