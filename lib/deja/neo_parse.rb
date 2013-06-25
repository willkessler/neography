module Deja
  module NeoParse
    extend ActiveSupport::Concern

    module ClassMethods
      def normalize(hash, type = :eager)
        case type
        when :eager then tier_array(sane_hash(hash))
        when :lazy  then tier_relations(sane_hash(hash))
        else return false end
      end

      private

      def sane_hash(hash)
        clean_array = []
        hash['data'].each do |slice|
          slice.each do |record|
            attr_hash = {}
            attr_hash[:id] = record['self'].split('/').last.to_i
            attr_hash[:type] = record['type'] if record['type']
            attr_hash[:start] = record['start'].split('/').last.to_i if record['start']
            attr_hash[:end] = record['end'].split('/').last.to_i if record['end']
            record['data'].each do |key, value|
              attr_hash[key.to_sym] = value
            end
            clean_array << attr_hash
          end
        end
        clean_array
      end

      def tier_relations(array)
        clean_hash = {}
        current_rel = nil
        current_type = nil

        array.each_with_index do  |record, index|
          unless record.has_key?(:start)
            clean_hash[current_type].map! do |v|
              v[:node] = record if v[:rel][:id] == current_rel
              v
            end
          else
            current_rel  = record[:id]
            current_type = record[:type]
            clean_hash[record[:type]] ||= []
            clean_hash[record[:type]] << {
              :node => {},
              :rel  => record
            }
          end
        end
        #puts clean_hash
        clean_hash
      end

      def tier_array(array)
        clean_array = []
        current_rel = nil
        current_type = nil
        array.each_with_index do |record, index|
          # we have a node
          unless record.has_key?(:start)
            # skip any repeated nodes
            unless clean_array.any?{|h| h[:id] == record[:id]}
              # the last iteration created a relationship
              if clean_array.last && clean_array.last[:relationships].empty? == false
                clean_array.last[:relationships][current_type].each do |relnode|
                  relnode[:node] = record if relnode[:rel][:id] == current_rel
                end
              # the last iteration wasn't a relationship, must be a new node
              else
                record[:relationships] = {}
                clean_array.push(record)
              end
            end
          # we have a relationship
          else
            current_rel = record[:id]
            current_type = record[:type]
            clean_array.last[:relationships][record[:type]] ||= []
            clean_array.last[:relationships][record[:type]] << {
              :node => {},
              :rel  => record
            }
          end
        end
        clean_array
      end
    end
  end
end