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
        hash['data'].each_with_index.map do |slice, i|
          ## if we are selecting specific columns, we trigger this first condition
          unless slice.first && slice.first.is_a?(Hash)
            Hash[hash['columns'].map{|x|(x.split('.')[1] || x).to_sym}.zip(slice)]
          ## otherwise we are grabbing every field and we parse the data
          else
            slice.map do |record|
              next unless record
              attr_hash = {
                :id   => record['self'].split('/').last.to_i,
                :type => record['type']
              }
              attr_hash[:start_node] = record['start'].split('/').last.to_i if record['start']
              attr_hash[:end_node]   = record['end'].split('/').last.to_i if record['end']
              record['data'].each do |key, value|
                attr_hash[key.to_sym] = value
              end
              attr_hash
            end
          end
        end.flatten
      end

      # tiers data based on r-node structure
      def structure_relationships(flat_array)
        build_tier(flat_array, :return => Hash) do |tier, rel, type, record|
          tier[type].map! do |v|
            v[:node] = record if v[:rel][:id] == rel
            v
          end
        end
      end

      # tiers data with node-r-node structure
      def structure_node_and_relationships(flat_array)
        build_tier(flat_array, :return => Array) do |tier, rel, type, record|
          # skip any repeated nodes based on id
          next if tier.any? { |h| h[:id] == record[:id] }
          # the last iteration created a relationship
          if tier.last && tier.last[:relationships].present?
            tier.last[:relationships][type].each do |relnode|
              relnode[:node] = record if relnode[:rel][:id] == rel
            end
          # the last iteration wasn't a relationship, must be a new node
          else
            record[:relationships] = {}
            tier.push(record)
          end
        end
      end

      private

      def build_tier(array, opts = {})
        opts[:return] ||= Array
        tiered_struct = opts[:return].new
        current_rel   = nil
        current_type  = nil

        array.each do |record|
          next unless record
          # we have a relationship
          if record.has_key?(:start_node)
            current_rel = record[:id]
            current_type = record[:type]
            rel_node = { :node => {}, :rel => record }
            if opts[:return] == Array
              tiered_struct.last[:relationships][record[:type]] ||= []
              tiered_struct.last[:relationships][record[:type]] << rel_node
            else
              tiered_struct[record[:type]] ||= []
              tiered_struct[record[:type]] << rel_node
            end
          # we have a node, let the block handle node assignment
          else
            yield(tiered_struct, current_rel, current_type, record) if block_given?
          end
        end
        tiered_struct
      end
    end
  end
end

