require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['-cfs']
end
task :default => :spec

desc "Release engineyard-serverside-adapter gem"
task :release do
  puts "Adapter DOES NOT bump serverside automatically anymore."
  puts "Please reference the serverside_version in the client."
  puts
  new_version = remove_pre

  run_commands("git tag v#{new_version}",
    "gem build engineyard-serverside-adapter.gemspec")

  next_pre(new_version)

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

def remove_pre
  require 'engineyard-serverside-adapter/version'
  version = EY::Serverside::Adapter::VERSION
  unless version =~ /\.pre$/
    raise "Version #{version.inspect} does not end with .pre, you should release manually if you want a custom version name."
  end
  new_version = version.gsub(/\.pre$/, '')
  puts "New version is #{new_version}"
  bump(new_version, "Bump to version #{new_version}")
  new_version
end

def next_pre(version)
  digits = version.scan(/(\d+)/).map { |x| x.first.to_i }
  digits[-1] += 1
  new_version = digits.join('.') + ".pre"
  puts "Next version is #{new_version}"
  bump(new_version, "Add .pre for next release")
end

def bump(new_version, commit_msg)
  contents = version_path.read.sub(/VERSION = "[^"]+"/, %|VERSION = "#{new_version}"|)
  version_path.unlink
  version_path.open('w') { |f| f.write contents }
  run_commands(
    "git add #{version_path}",
    "git commit -m '#{commit_msg}'")
end
