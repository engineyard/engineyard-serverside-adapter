module EY
  module Serverside
    class Adapter
      class Deploy < Action

        option :app,              :string,    :required => true
        option :account_name,     :string,    :required => true, :version => '>=2.0.0'
        option :environment_name, :string,    :required => true, :version => '>=2.0.0'
        option :stack,            :string,    :required => true
        option :instances,        :instances, :required => true
        option :config,           :json
        option :verbose,          :boolean
        option :framework_env,    :string,    :required => true

        option :migrate,          :string,    :include => true

        option :ref,              :string
        option :repo,             :string

        option :git,              :string
        option :archive,          :string

      private

        def task
          ['deploy']
        end

      end
    end
  end
end
