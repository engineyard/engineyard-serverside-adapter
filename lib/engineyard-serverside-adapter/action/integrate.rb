module EY::Serverside
  class Adapter
    class Action
      class Integrate < Action

        option :app,              :string,    :required => true
        option :account_name,     :string,    :required => true, :version => '>=2.0.0'
        option :environment_name, :string,    :required => true, :version => '>=2.0.0'
        option :stack,            :string,    :required => true
        option :instances,        :instances, :required => true
        option :framework_env,    :string,    :required => true
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
