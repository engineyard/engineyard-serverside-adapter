require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['-cfs']
end
task :default => :spec

desc "Release engineyard-serverside-adapter gem"
task :release do
  new_version = bump_to_latest_serverside
  (system("git add lib/engineyard-serverside-adapter/version.rb") &&
    system("git commit -am 'Bump to engineyard-serverside version #{new_version}'") &&
    system("git tag v#{new_version}") &&
    system("gem build engineyard-serverside-adapter.gemspec"))

  puts <<-PUSHGEM
## To publish the gem: #########################################################

    gem push engineyard-serverside-adapter-#{new_version}.gem
    git push origin master v#{new_version}

## No public changes yet. ######################################################
  PUSHGEM
end

def bump_to_latest_serverside
  specs = Gem::SpecFetcher.fetcher.fetch(Gem::Dependency.new("engineyard-serverside"))
  versions = specs.map {|spec,| spec.version}.sort
  new_version = versions.last.to_s

  serverside_version_file =<<-EOT
module EY
  module Serverside
    class Adapter
      VERSION = "#{new_version}"
      ENGINEYARD_SERVERSIDE_VERSION = ENV['ENGINEYARD_SERVERSIDE_VERSION'] || "#{new_version}"
    end
  end
end
  EOT

  puts "Using engineyard-serverside version #{new_version}"
  File.open('lib/engineyard-serverside-adapter/version.rb', 'w') do |f|
    f.write serverside_version_file
  end
  new_version
end
