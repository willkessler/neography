module Deja
  class Relationship
    extend ActiveModel::Naming
    extend ActiveModel::Callbacks
    extend ActiveModel::Translation

    include ActiveModel::Dirty
    include ActiveModel::Observing
    include ActiveModel::Validations
    include ActiveModel::MassAssignmentSecurity

    include Deja::Error
    include Deja::Index
    include Deja::Bridge
    include Deja::Finders

    attr_accessor :id, :label, :start_node, :end_node, :direction

    def initialize(id, label, start_node, end_node, direction = nil)
        @id, @label, @start_node, @end_node, @direction = id, label, start_node, end_node, direction
    end

    def save()

    end
  end
end
