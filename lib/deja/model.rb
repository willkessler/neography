module Deja
  class Model
    extend ActiveModel::Callbacks

    include ActiveModel::Model
    include ActiveModel::Dirty
    include ActiveSupport::Concern

    include Deja::Error
    include Deja::SchemaGenerator

    define_model_callbacks :initialize, :create, :update, :delete, :save

    after_save   :create_indices
    after_update :update_indices

    def initialize(*args)
      run_callbacks :initialize do
        @id = nil
        options = args.extract_options!
        super(options)
        yield(args) if block_given?
      end
    end

    def self.create(opts = {})
      obj = new(opts)
      obj.save
    end

    def self.create!(opts = {})
      obj = new(opts)
      obj.save!
    end

    def update!(opts = {})
      run_callbacks :update do
        opts.each { |attribute, value| send("#{attribute}=", value) }
        save!
      end
    end

    def update(opts = {})
      begin
        update!(opts)
        self
      rescue BadImplementationError => e
        raise e
      rescue StandardError
        false
      end
    end

    def self.do_not_serialize(*exclusions)
      @excluded_from_serialization ||= Set.new
      @excluded_from_serialization.merge(exclusions)
    end

    def serializable_hash
      @@all_attributes[self.class.name].reject { |k, v| self.class.excluded_from_serialization[k] }
    end

    def save
      begin
        save!
        self
      rescue BadImplementationError => e
        raise e
      rescue StandardError
        false
      end
    end

    def delete
      run_callbacks :delete do
        destroy
      end
    end

    def persisted?
      !!@id
    end

    def save!
      raise BadImplementationError.new "You must implement the #save! method in each class that includes Deja::Model"
    end

    def destroy
      raise BadImplementationError.new "You must implement the #destroy method in each class that includes Deja::Model"
    end

    def persisted_attributes
      raise BadImplementationError.new "You must implement the #persisted_attributes method in each class that includes Deja::Model"
    end

    class BadImplementationError < StandardError; end

    private

    def create_indices
      (self.class.indexed_attributes[self.class.name]||{}).each do |name|
        send("add_to_#{name}_index")
      end
    end

    def update_indices
      (self.class.indexed_attributes[self.class.name]||{}).each do |name|
        if(send("#{name}_changed?") == true)
          send("remove_from_#{name}_index")
          send("add_to_#{name}_index")
        end
      end
    end

    def add_to_index(index, key, value, unique = false)
      if self.is_a? Deja::Node
        Deja.add_node_to_index(index, key, value, self.neo_id, unique)
      else
        Deja.add_relationship_to_index(index, key, value)
      end
    end

    def remove_from_index(*args)
      if self.is_a? Deja::Node
        Deja.remove_node_from_index(*args)
      else
        Deja.remove_relationship_from_index(*args)
      end
    end

  end
end
