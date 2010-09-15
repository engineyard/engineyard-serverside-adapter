module EY
  module Serverside
    module Adapter
      class Rollback < Action

        option :app,       :string,    :required => true
        option :stack,     :string,    :required => true
        option :instances, :instances, :required => true
        option :config,    :json
        option :verbose,   :boolean

      private

        def task
          ['deploy', 'rollback']
        end

      end
    end
  end
end
