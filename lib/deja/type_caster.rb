module Deja
  module TypeCaster
    extend ActiveSupport::Concern

    # cast back to Ruby objects where representation in the graph is different
    def self.reversecast(attr_name, value, klass)
      return if value.nil?

      data_type = (klass.constantize.schema[:attributes][attr_name] || klass.constantize.composed_attributes[attr_name])[:type].to_s

      case data_type
      when 'Integer'
        value.to_i
      when 'Float'
        value.to_f
      when 'BigDecimal'
        BigDecimal.new(value.to_s)
      when 'String'
        value.to_s
      when 'Deja::Boolean'
        Boolean.true?(value)
      when 'Date'
        Date.parse(value.to_s)
      when 'Time'
        Time.at(value)
      else
        value
      end
    end

    # cast to neo4j basic types and raise errors when invalid/unrecognized data type
    def self.typecast(attr_name, value, klass)
      return if value.nil? || (value.is_a?(String) && value.empty?)

      data_type = (klass.constantize.schema[:attributes][attr_name] || klass.constantize.composed_attributes[attr_name])[:type].to_s

      case data_type
      when 'Integer'
        Integer(value)
      when 'Float'
        Float(value)
      when 'BigDecimal'
        BigDecimal(value.to_s).to_s
      when 'Deja::Boolean'
        raise TypeError, "invalid boolean value passed in: '#{value}'" unless Boolean.boolean?(value)
        Boolean.true?(value)
      when 'String'
        String(value)
      when 'Date'
        Date.parse(value.to_s).strftime("%Y-%m-%d").to_s
      when 'Time'
        value.to_i
      else
        raise TypeError, "undefined data type #{data_type} for attribute #{name}"
      end
    end
  end
end
