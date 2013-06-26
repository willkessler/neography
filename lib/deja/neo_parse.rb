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
      # separate neo4j returned data into flat array of node/relationship data
      def sane_hash(hash)
        hash['data'].map do |slice|
          slice.map do |record|
            attr_hash = {
              :id => record['self'].split('/').last.to_i,
              :type => record['type']
            }
            attr_hash[:start] = record['start'].split('/').last.to_i if record['start']
            attr_hash[:end] = record['end'].split('/').last.to_i if record['end']
            record['data'].each do |key, value|
              attr_hash[key.to_sym] = value
            end
            attr_hashß
          end
        end.flatten
      end

      # tiers a data based on r-node structure
      def tier_relations(array)
        clean_hash = {}
        current_rel = nil
        current_type = nil

        array.each do  |record|
          if record.has_key?(:start)
            current_rel  = record[:id]
            current_type = record[:type]
            clean_hash[record[:type]] ||= []
            clean_hash[record[:type]] << {
              :node => {},
              :rel  => record
            }
          else
            clean_hash[current_type].map! do |v|
              v[:node] = record if v[:rel][:id] == current_rel
              v
            end
          end
        end
        clean_hash
      end

      # tiers data with node-r-node structure
      def tier_array(array)
        clean_array = []
        current_rel = nil
        current_type = nil
        array.each do |record|
          # we have a node
          if record.has_key?(:start)
            current_rel = record[:id]
            current_type = record[:type]
            clean_array.last[:relationships][record[:type]] ||= []
            clean_array.last[:relationships][record[:type]] << {
              :node => {},
              :rel  => record
            }
          else
            # skip any repeated nodes
            next if clean_array.any? { |h| h[:id] == record[:id] }
            # the last iteration created a relationship
            if clean_array.last && !clean_array.last[:relationships].empty?
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
        end
      end
      clean_array
    end
  end
end
