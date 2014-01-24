module Deja
  module SchemaGenerator
    extend ActiveSupport::Concern
    include TypeCaster

    module ClassMethods
      @@all_attributes ||= {}
      @@indexed_attributes ||= {}
      @@composed_attributes ||= {}

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
        sym_name = name.to_sym
        self.define_class_key
        @@all_attributes[self.name][sym_name] = opts.merge(:type => type)
        attr_accessorize(sym_name, opts)
        add_property_to_index(sym_name) if opts[:index]
      end

      def attr_accessorize(name, opts)
        send(:attr_accessor, name)
        define_attribute_methods name
        define_method("#{name}=") do |new_value|
          send("#{name}_will_change!") if (new_value != instance_variable_get("@#{name}") && !instance_variable_get("@#{name}").nil?)
          instance_variable_set("@#{name}", new_value)
        end
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
        @@composed_attributes[self.name] ||= {}

        if attrs
          @@composed_attributes[self.name].merge!(attrs)
          # @@composed_attributes[self.name].uniq!
        else
          @@composed_attributes[self.name]
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
          if validator.respond_to? :attributes
            validator.attributes.each do |attr|
              memo[attr] ||= {}
              memo[attr][validator.kind] = validator.options
            end
            memo
          else
            memo
          end
        end
      end
    end
  end
end
