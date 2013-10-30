module Deja
  class Model
    extend ActiveModel::Callbacks

    include ActiveModel::Model
    include ActiveModel::Dirty
    include ActiveSupport::Concern
    include ActiveSupport::Inflector

    include Deja::Cast
    include Deja::Error
    include Deja::SchemaGenerator

    @@all_attributes = {}
    @@indexed_attributes = {}

    attr_reader :id

    define_model_callbacks :initialize, :create, :update, :delete, :save

    def initialize(*args)
      attrs = self.class.class_variable_get(:@@all_attributes)
      indexes = self.class.class_variable_get(:@@indexed_attributes)
      attrs[self.class.name] ||= {}
      indexes[self.class.name] ||= {}
      self.class.class_variable_set(:@@all_attributes, attrs)
      self.class.class_variable_set(:@@indexed_attributes, indexes)
      run_callbacks :initialize do
        @id = nil
        options = args.extract_options!
        options = options.select { |k, v| self.class.attributes.include?(k) || self.class.composed_attributes.include?(k)}
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

    def save!
      if persisted?
        update!
      else
        create!
      end
      self
    end

    def create
      begin
        create!
        true
      rescue
        false
      end
    end

    def update(opts = {})
      begin
        update!(opts)
        true
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
        true
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

    def create!
      raise BadImplementationError.new "You must implement the #create! method in each class that includes Deja::Model"
    end

    def update!
      raise BadImplementationError.new "You must implement the #update! method in each class that includes Deja::Model"
    end

    def destroy
      raise BadImplementationError.new "You must implement the #destroy method in each class that includes Deja::Model"
    end

    def persisted_attributes
      raise BadImplementationError.new "You must implement the #persisted_attributes method in each class that includes Deja::Model"
    end

    class BadImplementationError < StandardError; end
  end
end
