module EY::Serverside
  class Adapter
    class Action
      class Rollback < Action

        option :app,              :string,    :required => true
        option :account_name,     :string,    :required => true, :version => '>=2.0.0'
        option :environment_name, :string,    :required => true, :version => '>=2.0.0'
        option :config,           :json
        option :framework_env,    :string,    :required => true
        option :instance_names,   :hash,      :required => true
        option :instance_roles,   :hash,      :required => true
        option :instances,        :array,     :required => true
        option :stack,            :string,    :required => true
        option :verbose,          :boolean

      private

        def task
          ['deploy', 'rollback']
        end

      end

      # backwards compatibility
      EY::Serverside::Adapter::Rollback = Rollback
    end
  end
end
