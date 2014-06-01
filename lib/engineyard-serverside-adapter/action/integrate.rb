module EY::Serverside
  class Adapter
    class Action
      class Integrate < Action

        option :app,              :string,    :required => true
        option :account_name,     :string,    :required => true, :version => '>=2.0.0'
        option :environment_name, :string,    :required => true, :version => '>=2.0.0'
        option :stack,            :string,    :required => true
        option :instance_names,   :hash,      :required => true
        option :instance_roles,   :hash,      :required => true
        option :instances,        :array,     :required => true
        option :framework_env,    :string,    :required => true
        option :ignore_existing,  :boolean,                      :version => '>=2.4.0'
        option :verbose,          :boolean

      private

        def task
          ['integrate']
        end

      end

      # backwards compatibility
      EY::Serverside::Adapter::Integrate = Integrate
    end
  end
end
