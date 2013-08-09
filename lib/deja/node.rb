module Deja
  class Node < Model

    include Deja::Cast
    include Deja::Finders

    class << self
      attr_reader :relationship_names

      def relationships(*args)
        @relationship_names ||= Set.new
        args.each do |arg|
          @relationship_names << arg
          attr_writer arg
        end
      end
    end

    def initialize(*args)
      super do
        if self.class.relationship_names
          self.class.relationship_names.each do |rel|
            self.class.class_eval do
              define_method rel do
                rel_instance = instance_variable_get("@#{rel}")
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

    def count_relationships(type = :all)
      if type == :all
        Deja::Query.count_relationships(@id)
      else
        Deja::Query.count_relationships(@id, type)
      end
    end

    def save!
      if persisted?
        update
      else
        create
      end
    end

    def create
      run_callbacks :create do
        @id = Deja::Query.create_node(persisted_attributes)
      end
    end

    def update!(opts = {})
      opts.each { |attribute, value| send("#{attribute}=", value) }
      run_callbacks :update do
        Deja::Query.update_node(@id, persisted_attributes)
      end
    end

    def destroy
      Deja::Query.delete_node(@id) if @id
      @id = nil
    end

    def add_to_index(index, key, value, unique = false)
      Deja.add_node_to_index(index, key, value, @id, unique)
    end

    def remove_from_index(*args)
      Deja.remove_node_from_index(*args)
    end

    def persisted_attributes
      inst_vars = instance_variables.map { |i| i.to_s[1..-1].to_sym }
      attrs = (self.class.attributes + self.class.composed_attributes) & inst_vars
      attrs.inject({}) do |memo, (k, v)|
        memo[k] = send(k)
        memo
      end
    end
  end
end

