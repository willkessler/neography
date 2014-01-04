module Deja
  class Relationship < Model
    attr_accessor :start_node, :end_node

    class << self
      attr_reader :directionality, :cardinality

      @directionality = {}
      @cardinality = {}

      def from(from_type=nil, opts={})
        raise StandardError, "'from' and 'to' must be specified" unless from_type and opts.is_a? Hash and opts[:to]

        to_type = opts[:to]

        from_type = from_type.to_s.classify
        to_type = to_type.to_s.classify

        @directionality ||= {}
        @directionality[from_type] ||= []
        @directionality[from_type] << to_type

        @cardinality ||= {}
        @cardinality[:in] = opts[:cardinality].try(:[], :in)
        @cardinality[:out] = opts[:cardinality].try(:[], :out)
      end

      def valid_direction?(from_type=nil, to_type=nil)
        raise StandardError, "cannot check direction if 'from' and 'to' are not specified" unless from_type and to_type

        from_type = from_type.to_s.classify
        to_type = to_type.to_s.classify

        @directionality.key?(from_type) and @directionality[from_type].include?(to_type)
      end

      def label
        return self.name.underscore.to_sym
      end

      def cardinality(dir)
        @cardinality[dir]
      end

      def find(id_or_index)
        relationship = Deja::Query.load_relationship(id_or_index)
        relationize(relationship)
      end

      def where(key, value)
        find({:index => 'relationship_auto_index', :key =>  key, :value => value})
      end

      def find_between_nodes(start_node, end_node)
        relationship = Deja::Query.load_relationship_from_nodes(start_node.id, end_node.id, self.label)
        return nil if relationship.blank?
        relationize(relationship)
      end

      # Returns all (from_node, to_node pairs) for this relationship
      # e.g., [["Organization", "OrganizationAcquisitionActivity"], ["OrganizationAcquisitionActivity", "Organization"]]
      def node_pairs
        return [] if @directionality.blank?

        pairs = []
        @directionality.each do |from_node, to_nodes|
          to_nodes.map { |to| pairs << [from_node, to] }
        end
        pairs
      end

      def add_property_to_index(property)
        begin
          Deja.add_relationship_auto_index_property(property)
        ensure
          @@indexed_attributes[self.name] ||= []
          @@indexed_attributes[self.name] << property
        end
      end
    end

    # initialize(start_node, end_node, options = {})
    # the method below ensures that the relationship configuration is done between before_initialize and after_initialize
    def initialize(*args)
      super(*args) do |config|
        @start_node = config[0]
        @end_node   = config[1]
      end
    end

    def create!
      run_callbacks :save do
        run_callbacks :create do
          @id = Deja::Query.create_relationship(@start_node.id, @end_node.id, self.class.label, persisted_attributes)
          raise Deja::Error::OperationFailed, "Failed to create relationship" unless @id
        end
      end
      self
    end

    def update!(opts = {})
      opts.each { |attribute, value| send("#{attribute}=", value) }
      run_callbacks :save do
        run_callbacks :update do
          Deja::Query.update_relationship(@id, persisted_attributes)
        end
      end
      self
    end

    def destroy
      Deja::Query.delete_relationship(@id) if @id
      @id = nil
      true
    end

    def persisted_attributes
      inst_vars = instance_variables.map { |i| i.to_s[1..-1].to_sym }
      attrs = self.class.attributes & inst_vars
      attrs.inject({}) do |memo, (k, v)|
        memo[k] = TypeCaster.typecast(k, send(k), self.class.name)
        memo
      end
    end
  end
end
