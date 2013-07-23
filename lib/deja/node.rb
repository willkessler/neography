module Deja
  class Node < Model

    include Deja::Cast
    include Deja::Error
    include Deja::Finders
    include Deja::SchemaGenerator

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

    def related_nodes(*relationships)
      related_nodes = Deja::Query.load_related_nodes(self.id, :include => relationships)
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

    def save!
      if persisted?
        Deja::Query.update_node(@id, persisted_attributes)
      else
        run_callbacks :create do
          @id = Deja::Query.create_node(persisted_attributes)
        end
      end
    end

    def destroy
      Deja::Query.delete_node(@id) if @id
      @id = nil
    end

    def persisted_attributes
      run_callbacks :save do
        instance_variables.inject({}) do |memo, ivar|
          unless ivar && (ivar === :@id || ivar == :@relationships)
            attribute_name =  ivar.to_s[1..-1]
            memo[attribute_name] = send(attribute_name)
            puts "Added {'#{attribute_name}' => '#{send(attribute_name)}'} to persisted node attributes"
          end
          memo
        end
      end
    end

  end
end

