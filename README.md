EY::Serverside::Adapter
=======================

This library provides an interface bound to the same version of
engineyard-serverside.

It tries very hard to throw an exception whenever the caller does
anything wrong. The benefit of this is that you can depend on a newer
version of engineyard-serverside-adapter and run your tests; if they
pass, you can be fairly confident that your code will work with the
newer version of engineyard-serverside.

engineyard-serverside-adapter provides you with a builder to describe
a cluster, and yields commands to the block you pass. Because it knows
nothing about how to connect to a server, only what commands to run,
it can be used anywhere where interaction with engineyard-serverside
is needed.


Example
-------

This example is adapted from the engineyard gem:

    require 'engineyard-serverside-adapter'

    def adapter(app, verbose)
      EY::Serverside::Adapter.new("/usr/local/ey_resin/ruby/bin") do |args|
        args.app           = app.name
        args.repo          = app.repository_uri
        args.instances     = environment.instances.map { |i| {:hostname => i.public_hostname, :role => i.role, :name => i.name} }
        args.verbose       = verbose || ENV['DEBUG']
        args.stack         = environment.stack_name
        args.framework_env = environment.framework_env
      end
    end
    private :adapter

    def deploy(app, ref, migration_command=nil, extra_configuration=nil, verbose=false)
      deploy_command = adapter(app, verbose).deploy do |args|
        args.config  = extra_configuration if extra_configuration # anything that can be to_json'd
        args.migrate = migration_command if migration_command
        args.ref     = ref
      end

      deploy_command.call { |command| app_master.ssh(command) }
    end

You can set up args in Adapter.new, in Adapter#deploy (#rollback,
 #restart, etc.), or in both. A good idea is to set up common args
(e.g. app, instances) in Adapter.new and then supply deploy-specific
args to Adapter#deploy. We hope this lets your code stay DRY while
also avoiding unnecessary work from generating unnecessary args.

Releasing
---------

Bump the version in lib/engineyard-serverside-adapter/version.rb, commit it, and then run

    $ rake release

This will tag and push for you.

The engineyard gem depends on this gem to talk to the server side deploy mechanism.
Update the version of engineyard-serverside-adapter in engineyard's Gemfile to
interact with a new version of engineyard-serverside.
