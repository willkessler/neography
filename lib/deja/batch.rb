module Deja
  class Batch
    class << self
      def commit
        begin
          Deja.batch = []
          yield if block_given?
          Deja.neo.batch(*Deja.batch)
        ensure
          Deja.batch = nil
        end
      end
    end
  end
end
