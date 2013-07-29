module Deja
  module Cast

    extend ActiveSupport::Concern

    # creating relationships to be attached to already exisitng objects
    def erectify(hash)
      self.class.sans_initial_node(hash, self)
    end

    module ClassMethods
      # creating objects and their relationships (if any)
      def objectify(array)
        with_initial_node(array)
      end

      def with_initial_node(entity_array)
        initial_node = self.new(entity_array.first.except(ID).except(RELATIONSHIPS))
        initial_node.instance_variable_set("@#{ID}", entity_array.first[ID])
        sans_initial_node(entity_array.first[RELATIONSHIPS], initial_node)
        initial_node
      end

      def sans_initial_node(relation_hash, initial_node)
        return if relation_hash.nil? or relation_hash.empty?
        relation_hash.each do |name, relationship|
          relationship_array = relationship.map do |rel|
            if self.relationship_names.include?(rel[REL][TYPE].to_sym)
              node_class     = rel[NODE][TYPE].constantize
              related_node   = node_class.new(rel[NODE].except(ID))
              related_node.instance_variable_set("@#{ID}", rel[NODE][ID])
              rel_class      = rel[REL][TYPE].camelize.constantize
              rel_attributes = rel_class.attributes.inject({}) do |memo, (k, v)|
                memo[k]   = rel[REL][k]
                memo
              end
              relationship   = rel_class.new(rel[REL][TYPE], initial_node, related_node, 'both', rel_attributes)
              relationship.instance_variable_set("@#{ID}", rel[REL][ID])
              Deja::RelNodeWrapper.new(related_node, relationship)
            end
          end
          initial_node.send("#{name}=", relationship_array.compact) if self.relationship_names.include?(name.to_sym)
        end
      end

    end
  end
end
