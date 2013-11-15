require 'bundler'
require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'

begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

Bundler::GemHelper.install_tasks

$: << File.expand_path("#{File.dirname(__FILE__)}/lib")

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--color --format documentation"
  t.pattern = "spec/**/*_spec.rb"
end

desc 'Run Tests'
task :default => :spec

RSpec::Core::RakeTask.new('ci_spec')

desc 'Run Koality Tests'
task :ci_spec => 'ci:setup:rspec'
