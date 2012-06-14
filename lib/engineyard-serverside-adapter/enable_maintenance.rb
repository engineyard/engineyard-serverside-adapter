module EY
  module Serverside
    class Adapter
      class EnableMaintenance < Action

        option :app,              :string,    :required => true
        option :account_name,     :string,    :required => true
        option :environment_name, :string,    :required => true
        option :instances,        :instances, :required => true
        option :verbose,          :boolean

      private

        def task
          ['enable_maintenance']
        end

      end
    end
  end
end
