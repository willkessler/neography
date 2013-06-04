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

    @relationships = {}

    def initialize(opts = {})
      @relationships = {}
      opts.each { |k,v| instance_variable_set("@#{k}", v) }
    end

    def self.relationship(name, label, end_node_type)
      @relationships = {}
      @relationships[:label] = Deja::Relationship.new(:label, eval(end_node_type).new())
      class_eval %Q"
        def #{name}
          relationships[:label]
        end"
    end

    def save()
      node_attributes = {}
      instance_variables.each do |var|
        unless var == 'id' && !@id
          node_attributes[var.to_sym] = send(var.to_sym)
        end
      end
      unless @id
        #create
        Deja::Node.create_single_node(node_attributes)
      else
        #update
      end
    end

    def get_related_nodes()
      Deja::Node.get_related_nodes(@id)
    end

  end
end

