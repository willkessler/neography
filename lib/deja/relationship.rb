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
    include Deja::Bridge
    include Deja::Metaid
    include Deja::Finders

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
