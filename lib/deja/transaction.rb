module Deja
  class Transaction
    class << self
      def commit(&block)
        Deja.tx = Deja.neo.begin_transaction()
        yield
        Deja.neo.commit_transaction(Deja.tx)
        Deja.tx = nil
      end
    end
  end
end
