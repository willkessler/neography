module Deja
  module SchemaGenerator
    extend ActiveSupport::Concern

    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        extend ActiveModel::Translation
        include ActiveModel::Dirty
        include ActiveModel::Observing
        include ActiveModel::Validations
        include ActiveModel::MassAssignmentSecurity
      end
    end

    module ClassMethods
      def schema
        { :attributes => @attributes, :validations => validations }
      end

      def attributes(map)
        @attributes = map
        map.each do |attr, type|
          send(:attr_accessor, attr)
        end
      end

      private

      def validations
        validators.inject({}) do |memo, validator|
          validator.attributes.each do |attr|
            memo[attr] ||= {}
            memo[attr][validator.kind] = validator.options
          end
          memo
        end
      end
    end
  end
end
