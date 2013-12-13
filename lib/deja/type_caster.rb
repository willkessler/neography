module Deja
  module TypeCaster
    extend ActiveSupport::Concern

    included do
      # cast back to Ruby objects where representation in the graph is different
      def reversecast(attr_name, value)
        return nil if value.nil?

        data_type = self.class.schema[:attributes][attr_name][:type].to_s

        case data_type
        when 'Date'
          Date.parse(value.to_s)
        when 'Time'
          Time.at(value)
        else
          value
        end
      end

      # cast to neo4j basic types and raise errors when invalid/unrecognized data type
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
        when 'Date'
          Date.parse(value.to_s).strftime("%Y%m%d").to_i
        when 'Time'
          value.to_i
        else
          raise TypeError, "undefined data type #{data_type} for attribute #{name}"
        end
      end
    end
  end
end
