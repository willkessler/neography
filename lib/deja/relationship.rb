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
    include Deja::SchemaGenerator

    def initialize(id, label, start_node, end_node, direction = :none, attributes = nil)
      @id         = id
      @label      = label
      @start_node = start_node
      @end_node   = end_node
      @direction  = direction
      @attributes = attributes
    end

    def self.load()
      # stub
    end

    def save()
      rel_attributes = {}
      instance_variables.each do |var|
        attribute_name =  var.to_s[1..-1]
        rel_attributes[attribute_name] = send(attribute_name)
      end
      unless @id
        # create
        @id = Deja::Query.create_relationship(@start_node.id, @end_node.id, @label, @direction)
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
      Deja::Query.delete_relationship(@id) if @id
      @id = nil
    end

  end
end
