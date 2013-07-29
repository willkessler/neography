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
            next unless record
            attr_hash = {
              ID   => record['self'].split('/').last.to_i,
              TYPE => record[TYPE]
            }
            attr_hash[START_NODE] = record['start'].split('/').last.to_i if record['start']
            attr_hash[END_NODE]   = record['end'].split('/').last.to_i if record['end']
            record['data'].each do |key, value|
              attr_hash[key] = value
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
          if record.has_key?(START_NODE)
            current_rel  = record[ID]
            current_type = record[TYPE]
            tiered_hash[record[TYPE]] ||= []
            tiered_hash[record[TYPE]] << {
              NODE => {},
              REL  => record
            }
          else
            tiered_hash[current_type].map! do |v|
              v[NODE] = record if v[REL][ID] == current_rel
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
          next unless record
          # we have a node
          if record.has_key?(START_NODE)
            current_rel = record[ID]
            current_type = record[TYPE]
            tiered_array.last[RELATIONSHIPS][record[TYPE]] ||= []
            tiered_array.last[RELATIONSHIPS][record[TYPE]] << {
              NODE => {},
              REL  => record
            }
          else
            # skip any repeated nodes
            next if tiered_array.any? { |h| h[ID] == record[ID] }
            # the last iteration created a relationship
            if tiered_array.last && !tiered_array.last[RELATIONSHIPS].empty?
              tiered_array.last[RELATIONSHIPS][current_type].each do |relnode|
                relnode[NODE] = record if relnode[REL][ID] == current_rel
              end
            # the last iteration wasn't a relationship, must be a new node
            else
              record[RELATIONSHIPS] = {}
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
