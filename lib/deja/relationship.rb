module Deja
  class Relationship
    extend ActiveModel::Translation

    include ActiveModel::Dirty
    include ActiveModel::Observing
    include ActiveModel::Validations
    include ActiveModel::MassAssignmentSecurity

    include Deja::Bridge
    include Deja::Finders
    include Deja::Error

    attr_accessor :label, :node

    def initialize(label, node)
        @label = label
        @node = node
    end

    def save()

    end
  end
end
