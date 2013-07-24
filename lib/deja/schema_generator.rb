module Deja
  module SchemaGenerator
    extend ActiveSupport::Concern

    module ClassMethods
      @@all_attributes = {}
      @@indexed_attributes = []

      def schema
        {
          :attributes => inspect_attributes,
          :validations => inspect_validations
        }
      end

      def attribute(name, type, opts = {})
        @@all_attributes[self.name] ||= {}
        @@all_attributes[self.name][name] = opts.merge({:type => type})
        send(:attr_reader, name)
        define_method("#{name}=") do |new_value|
          send("#{name}_will_change!") if (new_value != instance_variable_get("@#{name}") && opts[:index])
          instance_variable_set("@#{name}", new_value)
        end
        if opts[:index]
          @@indexed_attributes[self.name] << name
          unique = opts[:unique] ? opts[:unique] : nil
          define_method("add_to_#{name}_index") do
            self.add_to_index("idx_#{self.name}_#{name}", self.send(name), self.id, unique)
          end
          define_method("remove_from_#{name}_index") do
            self.remove_from_index("idx_#{self.name}_#{name}", self.id)
          end
          private("add_to_#{name}_index")
          private("remove_from_#{name}_index")
        end
      end

      def index(name, attrs, opts = {})
        @@indexed_attributes << name
        define_attribute_method(name)
        unique = opts[:unique] ? opts[:unique] : nil
        define_method("add_to_#{name}_index") do
          keys = []
          attrs.each do |attr|
            keys << send(attr)
          end
          key = keys.join("^^^")
          self.add_to_index("idx_#{self.name}_#{name}", key, self.id, unique)
        end
        define_method("remove_from_#{name}_index") do
          self.remove_from_index("idx_#{self.name}_#{name}", self.id)
        end
        private("add_to_#{name}_index")
        private("remove_from_#{name}_index")
      end

      def indexed_attributes
        @@indexed_attributes
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
