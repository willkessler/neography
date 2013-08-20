module Deja
  class Node < Model

    include Deja::Cast
    include Deja::Finders

    class << self
      attr_reader :relationship_names

      def relationship(name, opts = {})
        raise StandardError, "'as' alias must be specified" unless opts.is_a? Hash and opts[:as]
        @relationship_names ||= {}
        if opts[:reverse] then
          @relationship_names[name] = {
            :out_singular => opts[:as].to_s.singularize,
            :out_plural   => opts[:as].to_s.pluralize,
            :in_singular  => opts[:reverse].to_s.singularize,
            :in_plural    => opts[:reverse].to_s.pluralize
          }
        else
          @relationship_names[name] = {
            :out_singular => opts[:as].to_s.singularize,
            :out_plural   => opts[:as].to_s.pluralize
          }
        end
        attr_writer name
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
        define_method aliases[:out_plural] do |filter = nil|
          r = send(:related_nodes, {:include => rel, :direction => :out, :filter => filter})
          instance_variable_get("@#{rel}")
        end

        define_method aliases[:out_singular] do |&b|
          relation = send(aliases[:out_plural]).first
          b.call(relation[0], relation[1]) if b
          relation
        end

        if aliases[:in_plural] and aliases[:in_singular] then
          define_method aliases[:in_plural] do |filter = nil|
            send(:related_nodes, {:include => rel, :direction => :in, :filter => filter})
            instance_variable_get("@#{rel}")
          end

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
        memo[rel_name] = instance_variable_get("@#{rel_name}")
        memo
      end
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

