module Deja
  class Node
    extend ActiveModel::Naming
    extend ActiveModel::Callbacks
    extend ActiveModel::Translation

    include ActiveModel::Dirty
    include ActiveModel::Observing
    include ActiveModel::Validations
    include ActiveModel::MassAssignmentSecurity

    include Deja::Cast
    include Deja::Error
    include Deja::Index
    include Deja::Bridge
    include Deja::Finders
    include Deja::SchemaGenerator

    attr_accessor :id

    class << self
      attr_accessor :relationships
    end

    def initialize(opts = {})
      @id = nil
      opts.each { |k, v| send("#{k}=", v)}
    end

    def self.relationship(name)
      @relationships ||= []
      @relationships.push(name.to_s)

      send(:attr_accessor, name)
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

    def save!
      save
    end

    def delete
      Deja::Node.delete_node(@id) if @id
      @id = nil
    end

    # def get_related_nodes
    #   Deja::Node.get_related_nodes(@id)
    # end

  end
end

