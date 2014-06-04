require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task :default => :spec


desc 'Run RSpec with code coverage'
task :coverage do
  ENV['SIMPLE_COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end
