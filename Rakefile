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
end

def bump_to_latest_serverside
  serverside_version_file =<<-EOT
  module EY
    module Serverside
      class Adapter
        VERSION = "_VERSION_GOES_HERE_"
      end
    end
  end
  EOT

  new_version = `gem search -r engineyard-serverside`.
    grep(/^engineyard-serverside /).
    first.
    match(/\((.*?)\)/).
    captures.
    first

  puts "Using engineyard-serverside version #{new_version}"
  File.open('lib/engineyard-serverside-adapter/version.rb', 'w') do |f|
    f.write serverside_version_file.gsub(/_VERSION_GOES_HERE_/, new_version)
  end
  new_version
end
