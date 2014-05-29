module EY::Serverside
  class Adapter
    class Action
      class Restart < Action

        option :app,              :string,    :required => true
        option :account_name,     :string,    :required => true, :version => '>=2.0.0'
        option :environment_name, :string,    :required => true, :version => '>=2.0.0'
        option :instances,        :instances, :required => true
        option :stack,            :string,    :required => true
        option :verbose,          :boolean

      private

        def task
          ['restart']
        end

      end

      # backwards compatibility
      EY::Serverside::Adapter::Restart = Restart
    end
  end
end
