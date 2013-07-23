module Deja
  class Relationship < Model

    include Deja::Error

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
        puts "Configuring relationship..."
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
        Deja::Query.update_relationship(@id, persisted_attributes)
      else
        run_callbacks :create do
          @id = Deja::Query.create_relationship(@start_node.id, @end_node.id, @label, @direction, persisted_attributes)
        end
      end
    end

    def destroy
      Deja::Query.delete_relationship(@id) if persisted?
      @id = nil
    end

    def persisted_attributes
      run_callbacks :save do
        my_attributes = self.class.list_attributes[self.class.name]
        my_attributes.keys.inject({}) { |memo, k| memo[k] = send(k); memo }
      end
    end

  end
end
