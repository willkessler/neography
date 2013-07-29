module Deja
  class Node < Model

    include Deja::Cast
    include Deja::Finders

    class << self
      attr_reader :relationship_names
    end

    def initialize(*args)
      super do
        if self.class.relationship_names
          self.class.relationship_names.each do |rel|
            rel_instance = instance_variable_get("@#{rel}")
            self.class.class_eval do
              define_method rel do
                if rel_instance
                  rel_instance
                else
                  send(:related_nodes, rel)
                  instance_variable_get("@#{rel}")
                end
              end
            end
          end
        end
      end
    end

    def related_nodes(*relationships)
      related_nodes = Deja::Query.load_related_nodes(@id, :include => relationships)
      erectify(related_nodes)
    end

    def relationships
      self.class.relationship_names.inject({}) do |memo, rel_name|
        memo[rel_name] = send("@#{rel_name}")
        memo
      end
    end

    def self.relationships(*args)
      @relationship_names ||= Set.new
      args.each do |arg|
        @relationship_names << arg
        attr_writer arg
      end
    end

    def count_relationships(type = :all)
      if type == :all
        Deja::Query.count_relationships(@id)
      else
        Deja::Query.count_relationships(@id, type)
      end
    end

    def save!
      if persisted?
        run_callbacks :update do
          Deja::Query.update_node(@id, persisted_attributes)
        end
      else
        run_callbacks :create do
          @id = Deja::Query.create_node(persisted_attributes)
        end
      end
    end

    def destroy
      if @id
        self.class.indexes.each do |name|
          self.remove_from_index("idx_#{self.class.name}", name, self.send(name), @id)
        end
        begin
          Deja::Query.delete_node(@id)
        rescue
          self.class.indexes.each do |name|
            self.add_to_index("idx_#{self.class.name}", name, self.send(name), @id)
          end
        end
      end
      @id = nil
    end

    def persisted_attributes
      self.class.attributes.inject({}) do |memo, (k, v)|
        memo[k] = send(k)
        memo
      end
    end
  end
end

