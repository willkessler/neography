module Deja
  class Node < Model

    include Deja::Cast
    include Deja::Error
    include Deja::Index
    include Deja::Finders
    include Deja::SchemaGenerator

    attr_reader :relationships

    after_initialize :setup_relationships

    def setup_relationships
      self.relationships ||= []
      self.relationships.each { |rel| setup_relationship(rel) }
    end

    def setup_relationship(rel)
      puts "Setting up relationship"
      rel_instance = instance_variable_get("@#{rel}")
      class_eval do
        define_method "self.#{rel}" do
          if rel_instance
            rel_instance
          else
            # lazy load if nil
            send(:related_nodes, rel.to_sym)
            instance_variable_get("@#{rel}")
          end
        end
      end
    end

    def self.relationship(name)
      @relationships ||= []
      @relationships.push(name.to_s)
      define_attribute_methods name
      send(:attr_reader, name)
      define_method("#{name}=") do |new_value|
        send("#{attr}_will_change!") unless new_value == send("#{attr}")
        send("@#{attr} = #{new_value}")
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
          unless ivar && ivar != :@id && ivar != :@relationships && ivar != :@changed_attributes
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

