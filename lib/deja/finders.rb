module Deja
  module Finders
    extend ActiveSupport::Concern
    module ClassMethods
      def find_by_index(index, key, value, options = {})
        option_query { Deja::Query.load_node({:index => index, :key => key, :value => value}, options) }
      end

      def find_by_neo_id(neo_id, options = {})
        option_query { Deja::Query.load_node(neo_id, options) }
      end

      def where(key, value, options = {})
        options[:include] ||= :all
        find_by_index("idx_#{self.name}", key, value, options)
      end

      private

      def option_query(&block)
        options = {}
        options[:include] ||= :all
        result = yield if block_given?
        objectify result
      end
    end
  end
end
