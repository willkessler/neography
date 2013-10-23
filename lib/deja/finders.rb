module Deja
  module Finders
    extend ActiveSupport::Concern
    module ClassMethods
      def find(id, options = {})
        option_query { Deja::Query.load_node(id, options) }
      end

      def where(key, value, options = {})
        options[:include] ||= :all
        find({:index => "idx_#{self.name}", :key => key, :value => value}, options)
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
