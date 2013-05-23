module Deja
  module Error
    class RecordNotFound  < StandardError; end

    class InvalidParameter < StandardError; end

    class NoParameter < StandardError
      def initialize
        super('No parameters passed')
      end
    end
  end
end
