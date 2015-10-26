require './app'

# activerecord を読み込み
require 'sinatra/activerecord/rake'


begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  # no rspec available
end