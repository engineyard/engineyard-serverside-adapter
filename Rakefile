require 'rspec/core/rake_task'
require 'date'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['-c']
end
task :default => :spec

desc "Release engineyard-serverside-adapter gem"
task :release do
  puts "Adapter DOES NOT bump serverside automatically anymore."
  puts "Please reference the serverside_version in the client."
  puts

  new_version = remove_pre
  write_version new_version
  release_changelog(new_version)

  run_commands(
    "git add ChangeLog.md #{version_path}",
    "git commit -m 'Bump versions for release #{new_version}'",
    "gem build engineyard-serverside-adapter.gemspec")

  write_version next_pre(new_version)

  run_commands(
    "git add #{version_path}",
    "git commit -m 'Add .pre for next release'",
    "git tag v#{new_version} HEAD^")

  puts <<-PUSHGEM
## To publish the gem: #########################################################

    gem push engineyard-serverside-adapter-#{new_version}.gem
    git push origin master v#{new_version}

## No public changes yet. ######################################################
  PUSHGEM
end

def version_path
  Pathname.new('lib/engineyard-serverside-adapter/version.rb')
end

def run_commands(*cmds)
  cmds.flatten.each do |c|
    system(c) or raise "Command #{c.inspect} failed to execute; aborting!"
  end
end

def release_changelog(version)
  clog = Pathname.new('ChangeLog.md')
  new_clog = clog.read.sub(/^## NEXT$/, <<-SUB.chomp)
## NEXT

  *

## v#{version} (#{Date.today})
  SUB
  clog.open('w') { |f| f.puts new_clog }
end

def remove_pre
  require 'engineyard-serverside-adapter/version'
  Gem::Version.create(EY::Serverside::Adapter::VERSION).release
end

def next_pre(version)
  digits = version.to_s.scan(/(\d+)/).map { |x| x.first.to_i }
  digits[-1] += 1
  new_version = digits.join('.') + ".pre"
end

def write_version(new_version)
  contents = version_path.read.sub(/VERSION = "[^"]+"/, %|VERSION = "#{new_version}"|)
  puts "engineyard-serverside-adapter (#{new_version})"
  version_path.unlink
  version_path.open('w') { |f| f.write contents }
end
