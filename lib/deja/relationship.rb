module Deja
  class Relationship < Model

    attr_accessor :label, :start_node, :end_node, :direction
    @connected_node_types = {}

    class << self
      def establish_connected_node_type(*nodes, key)
        @connected_node_types ||= {}
        nodes.each do |node|
          name = node.to_s.classify
          @connected_node_types[key] ||= Set.new
          @connected_node_types[key] << name
        end
      end

      def from(*nodes)
        establish_connected_node_type(*nodes, :from)
      end

      def to(*nodes)
        establish_connected_node_type(*nodes, :to)
      end

      def node_types
        @connected_node_types
      end
    end

    # initialize(label, start_node, end_node, direction, options = {})
    # the method below ensures that the relationship configuration is done between before_initialize and after_initialize
    def initialize(*args)
      super(*args) do |config|
        @label      = config[0]
        @start_node = config[1]
        @end_node   = config[2]
        @direction  = config[3]
      end
    end

    def self.load()
      # stub
    end

    def save!
      if persisted?
        run_callbacks :update do
          Deja::Query.update_relationship(@id, persisted_attributes)
        end
      else
        run_callbacks :create do
          @id = Deja::Query.create_relationship(@start_node.id, @end_node.id, @label, @direction, persisted_attributes)
        end
      end
    end

    def create
      @id = Deja::Query.create_relationship(@start_node.id, @end_node.id, @label, @direction, persisted_attributes)
      super
    end

    def update!(opts = {})
      opts.each { |attribute, value| send("#{attribute}=", value) }
      run_callbacks :update do
        Deja::Query.update_relationship(@id, persisted_attributes)
      end
    end

    def destroy
      Deja::Query.delete_relationship(@id) if @id
      @id = nil
    end

    def add_to_index(index, key, value, unique = false)
      Deja.add_relationship_to_index(index, key, value)
    end

    def remove_from_index(*args)
      Deja.remove_relationship_from_index(*args)
    end

    def persisted_attributes
      self.class.attributes.inject({}) do |memo, (k, v)|
        memo[k] = send(k)
        memo
      end
    end
  end
end
