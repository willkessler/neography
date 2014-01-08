module Deja
  class Node < Model
    class << self
      attr_reader :relationship_names
      attr_reader :aliases_hash

      def relationship_names
        @relationship_names || {}
      end

      def aliases_hash
        @aliases_hash || {}
      end

      def relationship(name, opts = {})
        raise StandardError, "'out' or 'in' aliases must be specified" unless opts.is_a? Hash and (opts[:out] or opts[:in])
        @relationship_names ||= {}
        @aliases_hash ||= {}

        if opts[:in]
          in_singular = opts[:in].to_s.singularize
          in_plural   = opts[:in].to_s.pluralize
          @aliases_hash[in_singular] = {
            :relationship => name, :direction => :in, :form => :singular}
          @aliases_hash[in_plural] = {
            :relationship => name, :direction => :in, :form => :plural}
          @relationship_names[name] ||= {}
          @relationship_names[name].merge!({
                      :in_singular  => in_singular,
                      :in_plural    => in_plural,
                      :in           => opts[:in]
                    })
        end
        if opts[:out]
          out_singular = opts[:out].to_s.singularize
          out_plural   = opts[:out].to_s.pluralize
          @aliases_hash[out_singular] = {
            :relationship => name, :direction => :out, :form => :singular}
          @aliases_hash[out_plural] = {
            :relationship => name, :direction => :out, :form => :plural}
          @relationship_names[name] ||= {}
          @relationship_names[name].merge!({
                      :out_singular => out_singular,
                      :out_plural   => out_plural,
                      :out          => opts[:out]
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

      def add_property_to_index(property)
        begin
          Deja.add_node_auto_index_property(property)
        ensure
          @@indexed_attributes[self.name] ||= []
          @@indexed_attributes[self.name] << property
        end
      end

      def find(id, options = {})
        result = Deja::Query.load_node(id, options)
        objectify result
      end

      def where(key, value, options = {})
        find({:index => "node_auto_index", :key => key, :value => value}, options)
      end

      def count(index)
        Deja::Query.count_nodes(index)
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
          define_method aliases[:out_plural] do |opts = {}|
            if instance_variable_get("@#{rel}").blank?
              send(:related_nodes, {:include => rel, :direction => :out}.merge(opts))
              instance_variable_get("@#{rel}").map {|r| r.end_node}
            else
              instance_variable_get("@#{rel}").inject([]) { |memo, rel| memo << rel.end_node; memo; }
            end
          end

          define_method "#{aliases[:out_plural]}=" do |relationship|
            current_rel = instance_variable_get("@#{rel}") || []
            current_rel << relationship
            instance_variable_set("@#{rel}", current_rel)
          end

          define_method aliases[:out_singular] do |opts = {}|
            send(aliases[:out_plural], opts).first
          end
        end

        if aliases[:in_plural] and aliases[:in_singular]
          define_method aliases[:in_plural] do |opts = {}|
            if instance_variable_get("@#{rel}").blank?
              send(:related_nodes, {:include => rel, :direction => :in}.merge(opts))
              instance_variable_get("@#{rel}").map {|r| r.start_node}
            else
              instance_variable_get("@#{rel}").inject([]) { |memo, rel| memo << rel.start_node; memo; }
            end
          end

          define_method "#{aliases[:in_plural]}=" do |relationship|
            current_rel = instance_variable_get("@#{rel}") || []
            current_rel << relationship
            instance_variable_set("@#{rel}", current_rel)
          end

          define_method aliases[:in_singular] do |opts = {}|
            send(aliases[:in_plural]).first
          end
        end
      end
    end

    def related_nodes(opts = {})
      related_nodes = Deja::Query.load_related_nodes(@id, opts)

      if related_nodes.empty? then
        instance_variable_set("@#{opts[:include]}", [])
      else
        erectify(related_nodes, opts[:direction])
      end
    end

    def relationships
      self.class.relationship_names.keys.inject({}) do |memo, rel_name|
        memo[rel_name] = instance_variable_get("@#{rel_name}") if instance_variable_get("@#{rel_name}")
        memo
      end
    end

    def count(rel_alias)
      rel_alias = rel_alias.to_s
      return false unless self.class.aliases_hash[rel_alias]
      Deja::Query.count_relationships(@id,
        self.class.aliases_hash[rel_alias][:relationship],
        self.class.aliases_hash[rel_alias][:direction])
    end

    def link(node_alias)
      node_alias = node_alias.to_s
      node_aliases = self.class.aliases_hash[node_alias]
      return false unless node_aliases
      related_nodes(:include => node_aliases[:relationship], :direction => node_aliases[:direction]) if instance_variable_get("@#{node_aliases[:relationship]}").blank?
      if node_aliases[:form] == :singular
        instance_variable_get("@#{node_aliases[:relationship]}").first
      else
        instance_variable_get("@#{node_aliases[:relationship]}")
      end
    end

    def connections
      return Deja::Query.count_connections(@id)
    end

    def outgoing_rel(type, cardinality="plural")
      self.class.outgoing_rel(type, cardinality)
    end

    def incoming_rel(type, cardinality="plural")
      self.class.incoming_rel(type, cardinality)
    end

    def create!
      run_callbacks :save do
        run_callbacks :create do
          @id = Deja::Query.create_node(persisted_attributes)
          raise Deja::Error::OperationFailed, "Failed to create node" unless @id
        end
      end
      self
    end

    def update!(opts = {})
      opts.each { |attribute, value| send("#{attribute}=", value) }
      updated_node = nil
      run_callbacks :save do
        run_callbacks :update do
          updated_node = Deja::Query.update_node(@id, persisted_attributes)
          self.class.objectify(updated_node)
        end
      end
    end

    def destroy
      Deja::Query.delete_node(@id) if @id
      @id = nil
      true
    end

    def persisted_attributes
      inst_vars = instance_variables.map { |i| i.to_s[1..-1].to_sym }
      attrs = (self.class.attributes + self.class.composed_attributes.keys) & inst_vars
      attrs.inject({}) do |memo, (k, v)|
        memo[k] = TypeCaster.typecast(k, send(k), self.class.name)
        memo
      end
    end
  end
end
