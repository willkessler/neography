module Deja
  module Finders
    extend ActiveSupport::Concern

    module ClassMethods
      def load(*ids)
        nodes = ids.map do |id|
          sane_hash = sane_hash(load_entity(id))

          node_instance = self.new(sane_hash.first)
          rel_instance = Deja::Relationship.new(sane_hash[1][:type], self.new(sane_hash[2]))
          node_instance.relationships.merge!(rel_instance.label.to_sym => rel_instance)
          node_instance
        end
        if ids.length == 1
          nodes.first
        else
          nodes
        end
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
