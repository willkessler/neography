module Deja
  class Node
    extend ActiveModel::Translation

    include ActiveModel::Dirty
    include ActiveModel::Observing
    include ActiveModel::Validations
    include ActiveModel::MassAssignmentSecurity

    include Deja::Bridge
    include Deja::Finders
    include Deja::Error

    begin
        @neo = Neography::Rest.new()
    rescue Neography::NeographyError
        exec('rake neo4j:start') if @neo.get_root[:reference_node]
        # Sets the test Neography connection
        @neo = Neography::Rest.new()
    end


    def initialize(*args)

    end

    def save()

    end
  end
end

