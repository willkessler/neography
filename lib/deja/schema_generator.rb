module Deja
  module SchemaGenerator
    extend ActiveSupport::Concern

    def self.included(base)
      base.class_eval do
        extend ActiveModel::Translation
        include ActiveModel::Dirty
        include ActiveModel::Observing
        include ActiveModel::Validations
        include ActiveModel::MassAssignmentSecurity
      end
    end

    module ClassMethods
      @@all_attributes = {}

      def schema
        {
          :attributes => inspect_attributes,
          :validations => inspect_validations
        }
      end

      def attributes(attrs)
        @@all_attributes[self.name] ||= {}
        @@all_attributes[self.name].merge!(attrs)
        attrs.each do |attr, type|
          send(:attr_accessor, attr)
        end
      end

      def inspect
        @@all_attributes
      end

      private

      def inspect_attributes
        klass = self
        attrs = {}

        while @@all_attributes.has_key?(klass.name)
          attrs.merge!(@@all_attributes[klass.name])
          klass = klass.superclass
        end

        attrs
      end

      def inspect_validations
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
