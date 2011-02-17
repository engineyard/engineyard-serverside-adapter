require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end
task :default => :spec

task :release do
  new_version = bump_to_latest_serverside
  (system("git add lib/engineyard-serverside-adapter/version.rb") &&
    system("git commit -am 'Bump to engineyard-serverside version #{new_version}'") &&
    system("git tag v#{new_version}") &&
    system("gem build engineyard-serverside-adapter.gemspec"))

  puts '********************************************************************************'
  puts
  puts "Don't forget to `gem push` and `git push --tags`!"
  puts
  puts '********************************************************************************'
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
