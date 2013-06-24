module Deja
  class Relationship
    extend ActiveModel::Naming
    extend ActiveModel::Callbacks
    extend ActiveModel::Translation

    include ActiveModel::Dirty
    include ActiveModel::Observing
    include ActiveModel::Validations
    include ActiveModel::MassAssignmentSecurity

    include Deja::Error
    include Deja::Index
    include Deja::Bridge
    include Deja::Finders
    include Deja::SchemaGenerator

    attr_accessor :id, :label, :start_node, :end_node, :direction

    def initialize(id, label, start_node, end_node, direction = :both)
        @id, @label, @start_node, @end_node, @direction = id, label, start_node, end_node, direction
    end

    def save()
      unless @id
        # create
        @id = Deja::Relationship.create_relationship(@start_node, @end_node, @label, @direction)
      else
        # update
        # still to be implemented
      end
    end
  end
end
