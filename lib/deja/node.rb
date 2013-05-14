module Deja
  class Node
    extend ActiveModel::Translation

    include ActiveModel::Dirty
    include ActiveModel::Observing
    include ActiveModel::MassAssignmentSecurity

    include Deja::Bridge
    include Deja::Finders
    include Deja::Error
    

    #
    # Dynamic attribute method generators
    #
    def initialize(*args)
      field = args.first

      if

    end

  end

end
