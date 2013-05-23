require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
require 'neography/tasks'

$: << File.expand_path("#{File.dirname(__FILE__)}/lib")

require 'deja'
require 'deja/tasks'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--color"
  t.pattern = "spec/**/*_spec.rb"
end

desc "Run Tests"
task :default => :spec


