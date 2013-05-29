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

    attr_accessor :id

    def initialize(opts={})
      opts.each { |k,v| instance_variable_set("@#{k}", v) }
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

