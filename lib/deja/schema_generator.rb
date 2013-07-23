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

      def attribute(name, opts = {})
        @@all_attributes[self.name] ||= {}
        @@all_attributes[self.name][name] = opts
        send(:attr_reader, name)
        define_method("#{name}=") do |new_value|
          instance_variable_set("@#{name}", new_value)
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
