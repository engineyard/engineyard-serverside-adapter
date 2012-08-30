module EY
  module Serverside
    class Adapter
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
    end
  end
end
