module EY
  module Serverside
    class Adapter
      class Integrate < Action

        option :app,           :string,    :required => true
        option :stack,         :string,    :required => true
        option :instances,     :instances, :required => true
        option :framework_env, :string,    :required => true
        option :verbose,       :boolean

      private

        def task
          ['integrate']
        end

      end
    end
  end
end
