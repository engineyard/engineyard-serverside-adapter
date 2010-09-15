module EY
  module Serverside
    class Adapter
      class Deploy < Action

        option :app,           :string,    :required => true
        option :stack,         :string,    :required => true
        option :instances,     :instances, :required => true
        option :config,        :json
        option :verbose,       :boolean
        option :framework_env, :string,    :required => true
        option :ref,           :string,    :required => true
        option :repo,          :string,    :required => true
        option :migrate,       :string

      private

        def task
          ['deploy']
        end

      end
    end
  end
end
