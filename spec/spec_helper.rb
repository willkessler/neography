require 'deja'
require 'neography/tasks'

def start_database
  namespace :neo4j do 
    task :start
  end
end
