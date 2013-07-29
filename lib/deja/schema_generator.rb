module Deja
  module SchemaGenerator
    extend ActiveSupport::Concern

    module ClassMethods
      @@all_attributes ||= {}
      @@indexed_attributes ||= {}

      def schema
        {
          :attributes => inspect_attributes,
          :validations => inspect_validations
        }
      end

      def attribute(name, type, opts = {})
        @@all_attributes[self.name] ||= {}
        @@all_attributes[self.name][name] = opts.merge(:type => type)
        send(:attr_reader, name)
        define_method("#{name}=") do |new_value|
          send("#{name}_will_change!") if (new_value != instance_variable_get("@#{name}") && opts[:index])
          instance_variable_set("@#{name}", new_value)
        end

        create_index_methods(name, nil, opts[:unique]) if opts[:index]
      end

      def create_index_methods(key, values = nil, unique = nil)
        define_attribute_method(key)
        @@indexed_attributes[self.name] ||= []
        @@indexed_attributes[self.name] << key
        define_method("add_#{key}_to_index") do
          value = values ? values.map{|attr| send(attr)}.join(INDEX_DELIM) : send(key)
          self.add_to_index("idx_#{self.class.name}", key, value, unique)
        end
        define_method("remove_#{key}_from_index") do
          self.remove_from_index("idx_#{self.class.name}", self.id)
        end
        private("add_#{key}_to_index")
        private("remove_#{key}_from_index")
      end

      def index(name, attrs, opts = {})
        create_index_methods(name, attrs, opts[:unique])
      end

      def indexed_attributes
        @@indexed_attributes
      end

      def all_attributes
        @@all_attributes
      end

      def attributes
        @@all_attributes[self.name] || {}
      end

      def indexes
        @@indexed_attributes[self.name] || []
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
