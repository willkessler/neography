module Deja
  module Finders
    extend ActiveSupport::Concern

    module ClassMethods
      def load(*ids)
        nodes = ids.map do |id|
          entity_array = load_entity(id)
          initial_node = self.new(entity_array.first.except(:relationships))
          entity_array.first[:relationships].each do |name, relationship|
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
          initial_node
        end
        if ids.length == 1
          nodes.first
        else
          nodes
        end
      end

      def load_single(id)
        self.new()
      end

      def find(*args, &block)
        case args.first
        when :all, :first
          kind = args.shift
          send(kind, *args, &block)
        when "0", 0, nil
          nil
        else
          if convertable_to_id?(*args.first)
            find_with_ids(*args)
          else
            first(*args, &block)
          end
        end
      end

      def find!(*args)
        self.find(*args).tap do |nodes|
          raise Deja::Error::RecordNotFound if nodes.nil?
        end
      end


      def all(*args, &block)
        if !condition_in?(*args)

        else

        end
      end
    end
  end
end
