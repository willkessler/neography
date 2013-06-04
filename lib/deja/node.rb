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

    attr_accessor :id, :relationships

    def initialize(opts = {})
      @id = nil
      @relationships = {}
      opts.each { |k,v| instance_variable_set("@#{k}", v) }
    end

    def self.relationship(name, label, end_node_type)
      @relationships = {}
      @relationships[:label] = Deja::Relationship.new(:label, :both, eval(end_node_type).new(), self)
      class_eval %Q"
        def #{name}
          relationships[:label]
        end"
    end

    def save
      node_attributes = {}
      instance_variables.each do |var|
        unless var == :@id || var == :@relationships
          node_attributes[var.to_s[1..-1]] = eval(var.to_s)
        end
      end
      unless @id
        # create
        @id = Deja::Node.create_node(node_attributes)
      else
        # update
        Deja::Node.update_node(@id, node_attributes)
      end
    end

    def delete
      Deja::Node.delete_node(@id) if @id
      @id = nil
    end

    def get_related_nodes
      Deja::Node.get_related_nodes(@id)
    end

  end
end

