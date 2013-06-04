module Deja
  module Error
    class RecordNotFound  < StandardError; end

    class InvalidParameter < StandardError; end

    class NoParameter < StandardError
      def initialize
        super ('No parameters passed')
      end
    end

    class NodeDoesNotExist < StandardError
      def initialize
        super ('could not find a node that matches your query')
      end
    end

    class RelationshipDoesNotExist < StandardError
      def initialize
        super ('could not find a relationship that matches your query')
      end
    end

    class CreationFailure < StandardError
      def initialize
        super ('there was an issue with creating this graph entity')
      end
    end
  end
end
