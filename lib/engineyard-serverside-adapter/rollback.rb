module EY
  module Serverside
    class Adapter
      class Rollback < Action

        option :app,              :string,    :required => true
        option :account_name,     :string,    :required => true, :version => '>=2.0.0'
        option :environment_name, :string,    :required => true, :version => '>=2.0.0'
        option :config,           :json
        option :framework_env,    :string,    :required => true
        option :instances,        :instances, :required => true
        option :stack,            :string,    :required => true
        option :verbose,          :boolean

      private

        def task
          ['deploy', 'rollback']
        end

      end
    end
  end
end
