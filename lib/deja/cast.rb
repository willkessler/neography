module Deja
  module Cast
    extend ActiveSupport::Concern

    def erectify(hash)
      self.class.sans_initial_node(hash, self)
    end

    module ClassMethods
      def objectify(array)
        with_initial_node(array)
      end

      def with_initial_node(entity_array)
        initial_node = self.new(entity_array.first.except(:relationships))
        sans_initial_node(entity_array.first[:relationships], initial_node)
        initial_node
      end

      def sans_initial_node(relation_hash, initial_node)
        relation_hash.each do |name, relationship|
          a = []
          relationship.each do |rel|
            if self.relationships.include?(rel[:rel][:type])
              node_class = rel[:node][:type].constantize
              related_node = node_class.new(rel[:node])
              relation = Deja::Relationship.new(rel[:rel][:id], rel[:rel][:type], initial_node, related_node)
              relation_bundle = Deja::RelNodeWrapper.new(related_node, relation)
              a.push(relation_bundle)
            end
          end
          initial_node.send("#{name}=", a) if self.relationships.include?(name)
        end
      end
    end
  end
end
