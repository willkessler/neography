module Deja
  module SchemaGenerator
    extend ActiveSupport::Concern

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
          #define_attribute_methods attr
          send(:attr_reader, attr)
          define_method("#{attr}=") do |new_value|
            # send("#{attr}_will_change!") unless new_value == send("#{attr}")
            instance_variable_set("@#{attr}", new_value)
          end
        end
      end

      def list_attributes
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
