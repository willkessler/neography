module Deja
  module Finders
    extend ActiveSupport::Concern

    module ClassMethods
      def load(*ids)
        nodes = ids.map do |id|
          entity_hash = sane_hash(load_entity(id))
          initial_node = self.new(entity_hash.first)
          related_nodes = Array.new
          puts entity_hash
          entity_hash.each do |entity|
            puts initial_node.class.relationships
            if entity.has_key?(:type)
              related_node = self.new(sane_hash(load_entity(entity[:start], :none)).first)
              if(initial_node.class.relationships.has_key?(entity[:type]))
                puts 'it does!'
                eval("initial_node.class.set_#{entity[:type]}(:#{entity[:type]}, :both, initial_node, related_node)")
              end
              related_nodes << related_node.id
            else
              unless entity[:id] == initial_node.id || related_nodes.include?(entity[:id])
                related_node = self.new(sane_hash(load_entity(entity[:id], :none)).first)
              end
            end
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
