module Deja
  class Relationship < Model

    include Deja::Cast

    attr_accessor :start_node, :end_node, :direction

    class << self
      @directionality = {}

      def from(from_type=nil, opts={})
        raise StandardError, "'from' and 'to' must be specified" unless from_type and opts.is_a? Hash and opts[:to]

        to_type = opts[:to]

        from_type = from_type.to_s.classify
        to_type = to_type.to_s.classify

        @directionality ||= {}
        @directionality[from_type] ||= []
        @directionality[from_type] << to_type
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

      def find(id_or_index)
        relationship = Deja::Query.load_relationship(id_or_index)
        relationize(relationship)
      end

      def find_between_nodes(start_node, end_node)
        relationship = Deja::Query.load_relationship_from_nodes(start_node.id, end_node.id, self.label)
        relationize(relationship)
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
      run_callbacks :create do
        @id = Deja::Query.create_relationship(@start_node.id, @end_node.id, self.class.label, persisted_attributes)
      end
      self
    end

    def update!(opts = {})
      opts.each { |attribute, value| send("#{attribute}=", value) }
      run_callbacks :update do
        Deja::Query.update_relationship(@id, persisted_attributes)
      end
      self
    end

    def destroy
      Deja::Query.delete_relationship(@id) if @id
      @id = nil
      true
    end

    def add_to_index(index, key, value, space = nil)
      Deja.add_relationship_to_index(index, key, value, @id)
    end

    def remove_from_index(*args)
      Deja.remove_relationship_from_index(*args)
    end

    def persisted_attributes
      inst_vars = instance_variables.map { |i| i.to_s[1..-1].to_sym }
      attrs = self.class.attributes & inst_vars
      attrs.inject({}) do |memo, (k, v)|
        memo[k] = send(k)
        memo
      end
    end
  end
end
