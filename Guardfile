guard 'rspec', :all_after_pass => true, :all_on_start => true, :cli => '--color' do

  lib = "lib/engineyard-serverside-adapter"

  watch(%r{^spec/(.+)_spec\.rb$})
  watch(%r{^#{lib}.rb$})           { "spec" }
  watch(%r{^#{lib}/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^#{lib}/action.rb$})    { "spec" }
  watch(%r{^#{lib}/command.rb$})   { "spec" }
  watch(%r{^#{lib}/option.rb$})    { "spec" }
  watch('spec/spec_helper.rb')     { "spec" }

end
