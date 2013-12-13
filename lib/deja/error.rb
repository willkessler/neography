module Deja
  module Error
    class RecordNotFound  < StandardError; end
    class InvalidParameter < StandardError; end
    class NoParameter < StandardError
      def initialize
        super('No parameters passed')
      end
    end
    class NodeDoesNotExist < StandardError; end
    class RelationshipDoesNotExist < StandardError; end
    class CreationFailure < StandardError; end
    class OperationFailed < StandardError; end
    class TypeError < StandardError; end
  end
end
