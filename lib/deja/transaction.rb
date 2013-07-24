module Deja
  class Transaction
    class << self
      def commit
        begin
          Deja.tx = Deja.neo.begin_transaction
          yield if block_given?
          Deja.neo.commit_transaction(Deja.tx)
        ensure
          Deja.tx = nil
        end
      end
    end
  end
end
