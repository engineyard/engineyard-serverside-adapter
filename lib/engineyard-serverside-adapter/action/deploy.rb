module EY::Serverside
  class Adapter
    class Action
      class Deploy < Action

        option :app,              :string,    :required => true
        option :account_name,     :string,    :required => true,      :version => '>= 2.0.0'
        option :archive,          :string,                            :version => '>= 2.3.0'
        option :clean,            :boolean,                           :version => '>= 2.3.2'
        option :config,           :json
        option :environment_name, :string,    :required => true,      :version => '>= 2.0.0'
        option :git,              :string,                            :version => '>= 2.3.0'
        option :framework_env,    :string,    :required => true
        option :instance_names,   :hash,      :required => true
        option :instance_roles,   :hash,      :required => true
        option :instances,        :array,     :required => true
        option :migrate,          :string,                            :include => true
        option :ref,              :string,    :required => '< 2.3.0'
        option :repo,             :string,    :required => '< 2.3.0', :version => '< 2.3.0'
        option :stack,            :string,    :required => true
        option :verbose,          :boolean

      private

        def task
          ['deploy']
        end

        def validate!
          super
          given = given_options.map{|opt| opt.name}
          if given.include?(:archive) && (given.include?(:git) || given.include?(:repo))
            raise ArgumentError, "Both :git & :archive options given. No precedence order is defined. Specify only one."
          elsif ([:git,:repo,:archive] & given).empty?
            raise ArgumentError, "Either :git or :archive options must be given."
          else
            # archive xor git
          end
        end
      end

      # backwards compatibility
      EY::Serverside::Adapter::Deploy = Deploy
    end
  end
end
