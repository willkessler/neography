require 'deja'
require 'spec_helper'
require 'rake/testtask'

class Friends < Relationship
  attribute :id, :type => Integer, :index => :exact
  attribute :name, :type => String
end

describe Deja::RestIndex do
  before :each do
    @first_node = FactoryGirl.create(:person);
    @second_node = FactoryGirl.create(:person);
    @relationship = Friends.new(:friends, @first_node, @second_node, :none)
  end

  describe "list indexes" do
    it "can get a listing of node indexes" do
      key = generate_text(6)
      value = generate_text
      Deja.add_node_to_index("test_node_index", key, value, @first_node.id)
      Deja.list_indexes.should_not be_nil
    end

    it "can get a listing of relationship indexes" do
      @relationship.save()
      key = generate_text(6)
      value = generate_text
      Deja.add_relationship_to_index("test_relationship_index", key, value, @relationship.id)
      Deja.list_relationship_indexes.should_not be_nil
    end
  end

  describe "create an index" do
    it "can create a node index" do
      name = generate_text(6)
      new_index = Deja.create_node_index(name)
      new_index.should_not be_nil
      new_index["template"].should == "#{Deja.neo.configuration}/index/node/#{name}/{key}/{value}"
      new_index["provider"].should == "lucene"
      new_index["type"].should == "exact"
    end

    it "can create a node index with options" do
      name = generate_text(6)
      new_index = Deja.create_node_index(name, "fulltext","lucene")
      new_index.should_not be_nil
      new_index["template"].should == "#{Deja.neo.configuration}/index/node/#{name}/{key}/{value}"
      new_index["provider"].should == "lucene"
      new_index["type"].should == "fulltext"
    end

    it "can create a relationship index" do
      name = generate_text(6)
      new_index = Deja.create_relationship_index(name)
      new_index.should_not be_nil
      new_index["template"].should == "#{Deja.neo.configuration}/index/relationship/#{name}/{key}/{value}"
      new_index["provider"].should == "lucene"
      new_index["type"].should == "exact"
    end

    it "can create a relationship index with options" do
      name = generate_text(6)
      new_index = Deja.create_relationship_index(name, "fulltext","lucene")
      new_index.should_not be_nil
      new_index["template"].should == "#{Deja.neo.configuration}/index/relationship/#{name}/{key}/{value}"
      new_index["provider"].should == "lucene"
      new_index["type"].should == "fulltext"
    end
  end

  describe "add to index" do
    it "can add a node to an index" do
      key = generate_text(6)
      value = generate_text
      Deja.add_node_to_index("test_node_index", key, value, @first_node.id)
      new_index = Deja.get_node_index("test_node_index", key, value)
      new_index.should_not be_nil
      Deja.remove_node_from_index("test_node_index", key, value, @first_node.id)
    end

    it "can add a relationship to an index" do
      @relationship.save
      key = generate_text(6)
      value = generate_text
      Deja.add_relationship_to_index("test_relationship_index", key, value, @relationship.id)
      new_index = Deja.get_relationship_index("test_relationship_index", key, value)
      new_index.should_not be_nil
      Deja.remove_relationship_from_index("test_relationship_index", key, value, @relationship.id)
    end
  end

  describe "remove from index" do
    it "can remove a node from an index" do
      key = generate_text(6)
      value = generate_text
      Deja.add_node_to_index("test_node_index", key, value, @first_node.id)
      new_index = Deja.get_node_index("test_node_index", key, value)
      new_index.should_not be_nil
      Deja.remove_node_from_index("test_node_index", key, value, @first_node.id)
      new_index = Deja.get_node_index("test_node_index", key, value)
      new_index.should be_nil
    end

    it "can remove a node from an index without supplying value" do
      key = generate_text(6)
      value = generate_text
      Deja.add_node_to_index("test_node_index", key, value, @first_node.id)
      new_index = Deja.get_node_index("test_node_index", key, value)
      new_index.should_not be_nil
      Deja.remove_node_from_index("test_node_index", key, @first_node.id)
      new_index = Deja.get_node_index("test_node_index", key, value)
      new_index.should be_nil
    end

    it "can remove a node from an index without supplying key nor value" do
      key = generate_text(6)
      value = generate_text
      Deja.add_node_to_index("test_node_index", key, value, @first_node.id)
      new_index = Deja.get_node_index("test_node_index", key, value)
      new_index.should_not be_nil
      Deja.remove_node_from_index("test_node_index", @first_node.id)
      new_index = Deja.get_node_index("test_node_index", key, value)
      new_index.should be_nil
    end

    it "can remove a relationship from an index" do
      @relationship.save
      key = generate_text(6)
      value = generate_text
      Deja.add_relationship_to_index("test_relationship_index", key, value, @relationship.id)
      new_index = Deja.get_relationship_index("test_relationship_index", key, value)
      new_index.should_not be_nil
      Deja.remove_relationship_from_index("test_relationship_index", key, value, @relationship.id)
      new_index = Deja.get_relationship_index("test_relationship_index", key, value)
      new_index.should be_nil
    end

    it "can remove a relationship from an index without supplying value" do
      @relationship.save
      key = generate_text(6)
      value = generate_text
      Deja.add_relationship_to_index("test_relationship_index", key, value, @relationship.id)
      new_index = Deja.get_relationship_index("test_relationship_index", key, value)
      new_index.should_not be_nil
      Deja.remove_relationship_from_index("test_relationship_index", key, @relationship.id)
      new_index = Deja.get_relationship_index("test_relationship_index", key, value)
      new_index.should be_nil
    end

    it "can remove a relationship from an index without supplying key nor value" do
      @relationship.save
      key = generate_text(6)
      value = generate_text
      Deja.add_relationship_to_index("test_relationship_index", key, value, @relationship.id)
      new_index = Deja.get_relationship_index("test_relationship_index", key, value)
      new_index.should_not be_nil
      Deja.remove_relationship_from_index("test_relationship_index", @relationship.id)
      new_index = Deja.get_relationship_index("test_relationship_index", key, value)
      new_index.should be_nil
    end

    it "throws an error when there is an empty string in the value when removing a node" do
      key = generate_text(6)
      value = generate_text
      Deja.add_node_to_index("test_node_index", key, value, @first_node.id)
      new_index = Deja.get_node_index("test_node_index", key, value)
      new_index.should_not be_nil
      expect { Deja.remove_node_from_index("test_node_index", key, "", @first_node.id) }.to raise_error Neography::NeographyError
    end
  end
end
