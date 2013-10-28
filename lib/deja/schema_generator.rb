module Deja
  module SchemaGenerator
    extend ActiveSupport::Concern

    module ClassMethods
      @@all_attributes ||= {}
      @@indexed_attributes ||= {}
      @@composed_attributes ||= []

      def schema
        {
          :attributes => inspect_attributes,
          :validations => inspect_validations
        }
      end

      def define_class_key
        @@all_attributes[self.name] ||= {}
      end

      def attribute(name, type, opts = {})
        self.define_class_key
        @@all_attributes[self.name][name] = opts.merge(:type => type)
        send(:attr_accessor, name)
        add_property_to_index(name) if opts[:index]
      end

      def indexed_attributes
        @@indexed_attributes
      end

      def all_attributes
        @@all_attributes
      end

      def attributes
        inspect_attributes.keys || []
      end

      def indexes
        @@indexed_attributes[self.name] || []
      end

      def composed_attributes(attrs = nil)
        if attrs
          @@composed_attributes += attrs
          @@composed_attributes.uniq!
        else
          @@composed_attributes
        end
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
