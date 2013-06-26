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
    include Deja::SchemaGenerator

    attr_accessor :id, :label, :start_node, :end_node, :direction

    def initialize(id, label, start_node, end_node, direction = :none)
      @id, @label, @start_node, @end_node, @direction = id, label, start_node, end_node, direction
    end

    def self.load()
      # stub
    end

    def save()
      unless @id
        # create
        @id = Deja::Relationship.create_relationship(@start_node.id, @end_node.id, @label, @direction)
      else
        # update
        # still to be implemented
      end
    end

    # convenience for factory_girl create()
    def save!
      save
    end

    def delete
      Deja::Relationship.delete_relationship(@id) if @id
      @id = nil
    end

  end
end
