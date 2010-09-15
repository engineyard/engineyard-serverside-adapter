module EY
  module Serverside
    class Adapter
      class Rollback < Action

        option :app,           :string,    :required => true
        option :config,        :json
        option :framework_env, :string,    :required => true
        option :instances,     :instances, :required => true
        option :stack,         :string,    :required => true
        option :verbose,       :boolean

      private

        def task
          ['deploy', 'rollback']
        end

      end
    end
  end
end
