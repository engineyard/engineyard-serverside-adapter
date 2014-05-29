module EY::Serverside
  class Adapter
    class Action
      class DisableMaintenance < Action

        option :app,              :string,    :required => true
        option :account_name,     :string,    :required => true, :version => '>=2.0.0'
        option :environment_name, :string,    :required => true, :version => '>=2.0.0'
        option :instances,        :instances, :required => true
        option :verbose,          :boolean

      private

        def task
          ['disable_maintenance']
        end

      end

      # backwards compatibility
      EY::Serverside::Adapter::DisableMaintenance = DisableMaintenance
    end
  end
end
