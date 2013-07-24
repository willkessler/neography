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
        initial_node = self.new(entity_array.first.except(RELATIONSHIPS))
        sans_initial_node(entity_array.first[RELATIONSHIPS], initial_node)
        initial_node
      end

      def sans_initial_node(relation_hash, initial_node)
        relation_hash.each do |name, relationship|
          relationship_array = relationship.map do |rel|
            if self.relationship_names.include?(rel[REL][TYPE].to_sym)
              node_class     = rel[NODE][TYPE].constantize
              related_node   = node_class.new(rel[NODE])
              rel_class      = rel[REL][TYPE].camelize.constantize
              rel_attributes = rel_class.list_attributes.inject({}) do |memo, attr|
                memo[attr]   = rel[REL][attr]
                memo
              end
              relationship   = rel_class.new(rel[REL][ID], rel[REL][TYPE], initial_node, related_node, rel_attributes)
              Deja::RelNodeWrapper.new(related_node, relationship)
            end
          end
          initial_node.send("#{name}=", relationship_array.compact) if self.relationship_names.include?(name.to_sym)
        end
      end

    end
  end
end
