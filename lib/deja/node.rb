module Deja
  class Node < Model

    include Deja::Cast
    include Deja::Error
    include Deja::Index
    include Deja::Finders
    include Deja::SchemaGenerator

    class << self
      attr_reader :relationships

      def relationships(*args)
        @relationships ||= Set.new
        args.each do |arg|
          name = arg.to_s
          @relationships << name
          attr_writer name
        end
      end
    end

    def related_nodes(*relationships)
      related_nodes = Deja::Query.load_related_nodes(self.id, :include => relationships)
      erectify(related_nodes)
    end

    def relationships
      self.class.relationships.inject({}) do |memo, rel_name|
        memo[rel_name] = send("@#{rel_name}")
        memo
      end
    end

    def initialize
      super do
        self.class.relationships.each do |rel|
          class_eval do
            define_method rel do
              send(:related_nodes, rel.to_sym) unless send("@#{rel}")
              send("@#{rel}")
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
          unless ivar && ivar != :@id && ivar != :@relationships
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

