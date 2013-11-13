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

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Deja'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

RSpec::Core::RakeTask.new('spec')

desc "Run Tests"
task :spec => 'ci:setup:rspec'
task :default => :spec
