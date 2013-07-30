module Deja
  module Finders
    extend ActiveSupport::Concern
    module ClassMethods
      def find_by_index(index, key, value, options = {})
        options[:include] ||= :all
        entity_array = Deja::Query.load_node({:index => index, :key => key, :value => value}, options)
        objectify(entity_array)
      end

      def find_by_neo_id(neo_id, options = {})
        options[:include] ||= :all
        entity_array = Deja::Query.load_node(neo_id, options)
        objectify(entity_array)
      end

      def where(key, value, options = {})
        options[:include] ||= :all
        find_by_index("idx_#{self.name}", key, value, options)
      end
    end
  end
end
