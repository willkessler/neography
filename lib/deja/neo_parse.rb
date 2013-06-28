module Deja
  module NeoParse
    extend ActiveSupport::Concern

    module ClassMethods
      def normalize(hash, type = :eager)
        return structure_node_and_relationships(sane_hash(hash)) if type == :eager
        return structure_relationships(sane_hash(hash)) if type == :lazy
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
            attr_hash
          end
        end.flatten
      end

      # tiers data based on r-node structure
      def structure_relationships(flat_hash)
        tiered_hash = {}
        current_rel = nil
        current_type = nil

        flat_hash.each do  |record|
          if record.has_key?(:start)
            current_rel  = record[:id]
            current_type = record[:type]
            tiered_hash[record[:type]] ||= []
            tiered_hash[record[:type]] << {
              :node => {},
              :rel  => record
            }
          else
            tiered_hash[current_type].map! do |v|
              v[:node] = record if v[:rel][:id] == current_rel
              v
            end
          end
        end
        tiered_hash
      end

      # tiers data with node-r-node structure
      def structure_node_and_relationships(flat_array)
        tiered_array = []
        current_rel = nil
        current_type = nil
        flat_array.each do |record|
          # we have a node
          if record.has_key?(:start)
            current_rel = record[:id]
            current_type = record[:type]
            tiered_array.last[:relationships][record[:type]] ||= []
            tiered_array.last[:relationships][record[:type]] << {
              :node => {},
              :rel  => record
            }
          else
            # skip any repeated nodes
            next if tiered_array.any? { |h| h[:id] == record[:id] }
            # the last iteration created a relationship
            if tiered_array.last && !tiered_array.last[:relationships].empty?
              tiered_array.last[:relationships][current_type].each do |relnode|
                relnode[:node] = record if relnode[:rel][:id] == current_rel
              end
            # the last iteration wasn't a relationship, must be a new node
            else
              record[:relationships] = {}
              tiered_array.push(record)
            end
          end
        # we have a relationship
        end
        tiered_array
      end
    end
  end
end
