module EY::Serverside
  class Adapter
    class Action
      class EnableMaintenance < Action

        option :app,              :string,    :required => true
        option :account_name,     :string,    :required => true, :version => '>=2.0.0'
        option :config,           :json
        option :environment_name, :string,    :required => true, :version => '>=2.0.0'
        option :instance_names,   :hash,      :required => true
        option :instance_roles,   :hash,      :required => true
        option :instances,        :array,     :required => true
        option :verbose,          :boolean

      private

        def task
          ['enable_maintenance']
        end

      end

      # backwards compatibility
      EY::Serverside::Adapter::EnableMaintenance = EnableMaintenance
    end
  end
end
