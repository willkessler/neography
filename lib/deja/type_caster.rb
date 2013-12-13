module Deja
  module TypeCaster
    extend ActiveSupport::Concern

    included do
      def typecast(attr_name, value)
        return nil if value.nil?

        data_type = self.class.schema[:attributes][attr_name][:type].to_s

        case data_type
        when 'Integer'
          Integer(value)
        when 'Float'
          Float(value)
        when 'Deja::Boolean'
          raise TypeError, "invalid boolean value passed in: '#{value}'" unless Boolean.boolean?(value)
          Boolean.true?(value)
        when 'String'
          String(value)
        else
          raise TypeError, "undefined data type #{data_type} for attribute #{name}"
        end
      end
    end
  end
end
