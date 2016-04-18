require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb'] # optional
end

task default: :spec

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['SIMPLE_COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end
