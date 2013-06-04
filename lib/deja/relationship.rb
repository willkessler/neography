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

    attr_accessor :label, :start_node, :end_node, :direction

    def initialize(label, direction, start_node, end_node)
        @label = label
        @direction = direction
        @start_node = start_node
        @end_node = end_node
    end

    def save()

    end
  end
end
