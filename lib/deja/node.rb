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
      # override all relationship read accessors
      if self.class.relationships
        self.class.relationships.each do |rel|
          rel_instance = instance_variable_get("@#{rel}")
          self.class.class_eval do
            define_method rel do
              if rel_instance
                rel_instance
              else
                # lazy load if nil
                send(:load_related, rel.to_sym)
                instance_variable_get("@#{rel}")
              end
            end
          end
        end
      end
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

    # convenience for factory_girl create()
    def save!
      save
    end

    def delete
      Deja::Node.delete_node(@id) if @id
      @id = nil
    end

  end
end

