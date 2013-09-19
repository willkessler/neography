module Deja
  class Node < Model

    include Deja::Cast
    include Deja::Finders

    class << self
      attr_reader :relationship_names

      def relationship(name, opts = {})
        raise StandardError, "'out' or 'in' aliases must be specified" unless opts.is_a? Hash and (opts[:out] or opts[:in])
        @relationship_names ||= {}
        if opts[:in]
          @relationship_names[name] ||= {}
          @relationship_names[name].merge!({
                      :in_singular  => opts[:in].to_s.singularize,
                      :in_plural    => opts[:in].to_s.pluralize
                    })
        end
        if opts[:out]
          @relationship_names[name] ||= {}
          @relationship_names[name].merge!({
                      :out_singular => opts[:out].to_s.singularize,
                      :out_plural   => opts[:out].to_s.pluralize
                    })
        end
        attr_writer name
      end

      def outgoing_rel(type, cardinality="plural")
        return nil unless @relationship_names and @relationship_names[type.underscore.to_sym]
        selector = ("out_" + cardinality).to_sym
        @relationship_names[type.underscore.to_sym][selector]
      end

      def incoming_rel(type, cardinality="plural")
        return nil unless @relationship_names and @relationship_names[type.underscore.to_sym]
        selector = ("in_" + cardinality).to_sym
        @relationship_names[type.underscore.to_sym][selector]
      end
    end

    def initialize(*args)
      super do
        if self.class.relationship_names
          self.class.relationship_names.each do |rel, aliases|
            define_alias_methods(rel, aliases)
          end
        end
      end
    end

    def define_alias_methods(rel, aliases)
      self.class_eval do
        if aliases[:out_plural] and aliases[:out_singular]
          define_method aliases[:out_plural] do |filter = nil|
            send(:related_nodes, {:include => rel, :direction => :out, :filter => filter})
            instance_variable_get("@#{rel}")
          end

          define_method "#{aliases[:out_plural]}=" do |relationship|
            current_rel = instance_variable_get("@#{rel}") || []
            current_rel << [relationship.end_node, relationship]
            instance_variable_set("@#{rel}", current_rel)
          end

          alias_method "#{aliases[:out_plural]}<<", "#{aliases[:out_plural]}="

          define_method aliases[:out_singular] do |&b|
            relation = send(aliases[:out_plural]).first
            b.call(relation[0], relation[1]) if b
            relation
          end
        end

        if aliases[:in_plural] and aliases[:in_singular]
          define_method aliases[:in_plural] do |filter = nil|
            send(:related_nodes, {:include => rel, :direction => :in, :filter => filter})
            instance_variable_get("@#{rel}")
          end

          define_method "#{aliases[:in_plural]}=" do |relationship|
            current_rel = instance_variable_get("@#{rel}") || []
            current_rel << [relationship.start_node, relationship]
            instance_variable_set("@#{rel}", current_rel)
          end

          alias_method "#{aliases[:in_plural]}<<", "#{aliases[:in_plural]}="

          define_method aliases[:in_singular] do |&b|
            relation = send(aliases[:in_plural]).first
            b.call(relation[0], relation[1]) if b
            relation
          end
        end
      end
    end

    def related_nodes(opts = {})
      related_nodes = Deja::Query.load_related_nodes(@id, opts)

      if related_nodes.empty? then
        instance_variable_set("@#{opts[:include]}", [])
      else
        erectify(related_nodes)
      end
    end

    def relationships
      self.class.relationship_names.keys.inject({}) do |memo, rel_name|
        memo[rel_name] = instance_variable_get("@#{rel_name}") if instance_variable_get("@#{rel_name}")
        memo
      end
    end

    def outgoing_rel(type, cardinality="plural")
      self.class.outgoing_rel(type, cardinality)
    end

    def incoming_rel(type, cardinality="plural")
      self.class.incoming_rel(type, cardinality)
    end

    def count_relationships(type = :all)
      if type == :all
        Deja::Query.count_relationships(@id)
      else
        Deja::Query.count_relationships(@id, type)
      end
    end

    def create!
      run_callbacks :create do
        @id = Deja::Query.create_node(persisted_attributes)
      end
      self
    end

    def update!(opts = {})
      opts.each { |attribute, value| send("#{attribute}=", value) }
      run_callbacks :update do
        Deja::Query.update_node(@id, persisted_attributes)
      end
      self
    end

    def destroy
      Deja::Query.delete_node(@id) if @id
      @id = nil
      true
    end

    def add_to_index(index, key, value, unique = false)
      Deja.add_node_to_index(index, key, value, @id, unique)
    end

    def remove_from_index(index, key, value)
      Deja.remove_node_from_index(index, key, value, @id)
    end

    def persisted_attributes
      inst_vars = instance_variables.map { |i| i.to_s[1..-1].to_sym }
      attrs = (self.class.attributes + self.class.composed_attributes) & inst_vars
      attrs.inject({}) do |memo, (k, v)|
        memo[k] = send(k)
        memo
      end
    end
  end
end
