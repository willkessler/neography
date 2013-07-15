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

    attr_accessor :label, :start_node, :end_node, :direction

    def initialize(label, start_node, end_node, direction, attrs = {})
      @label = label
      @start_node = start_node
      @end_node = end_node
      @direction = direction
      attrs.each { |k, v| send("#{k}=", v) }
    end

    def self.load()
      # stub
    end

    def save()
      rel_attributes = {}
      self.class.list_attributes[self.class.name].each do |k, v|
        rel_attributes[k] = send(k)
      end
      unless @id
        # create
        @id = Deja::Query.create_relationship(@start_node.id, @end_node.id, @label, @direction, rel_attributes)
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
