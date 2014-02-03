module Deja
  module SchemaGenerator
    extend ActiveSupport::Concern
    include TypeCaster

    module ClassMethods
      @@all_attributes ||= {}
      @@indexed_attributes ||= {}
      @@composed_attributes ||= {}
      @@editable_attributes ||= {}

      def schema
        {
          :attributes => inspect_attributes,
          :editable_attributes => inspect_editable_attributes,
          :validations => inspect_validations
        }
      end

      def define_class_key
        @@all_attributes[self.name] ||= {}
        @@editable_attributes[self.name] ||= []
      end

      def attribute(name, type, opts = {})
        sym_name = name.to_sym
        self.define_class_key
        @@all_attributes[self.name][sym_name] = opts.merge(:type => type)
        attr_accessorize(sym_name, opts)
        add_property_to_index(sym_name) if opts[:index]
        @@editable_attributes[self.name] << sym_name if opts[:editable] != false
      end

      def attr_accessorize(name, opts)
        send(:attr_accessor, name)
        define_attribute_methods name
        define_method("#{name}=") do |new_value|
          send("#{name}_will_change!") if (new_value != instance_variable_get("@#{name}") && !instance_variable_get("@#{name}").nil?)
          instance_variable_set("@#{name}", new_value)
        end
      end

      def editable_attributes
        @@editable_attributes
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

      def inspect_editable_attributes
        klass = self
        attrs = []
        while @@editable_attributes.has_key?(klass.name)
          attrs += @@editable_attributes[klass.name]
          klass = klass.superclass
        end
        attrs
      end

      def inspect_validations(for_json = false)
        validators.inject({}) do |memo, validator|
          if validator.respond_to? :attributes
            validator.attributes.each do |attr|
              memo[attr] ||= {}

              if for_json
                options = validator.options.deep_dup
                options[:with] = json_regexp(options[:with]) if options.has_key?(:with)
                memo[attr][validator.kind] = options
              else
                memo[attr][validator.kind] = validator.options
              end

            end
            memo
          else
            memo
          end
        end
      end

      # The following method (extracted from rails) adds support for sharing ruby regular expressions with javascript via JSON.

      # For more details, see http://www.edgerails.info/2013/1/21/whats-new-55/ and
      # https://github.com/rails/rails/blob/b67043393b5ed6079989513299fe303ec3bc133b/actionpack/lib/action_dispatch/routing/inspector.rb#L42

      def json_regexp(regexp)
        str = regexp.inspect.
              sub('\\A', '^').
              sub('\\Z', '$').
              sub('\\z', '$').
              sub(/^\//, '').
              sub(/\/[a-z]*$/, '').
              gsub(/\(\?#.+\)/, '').
              gsub(/\(\?-\w+:/, '(').
              gsub(/\s/, '')
        Regexp.new(str).source
      end
    end
  end
end
