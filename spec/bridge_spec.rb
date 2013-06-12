require 'deja'
require 'spec_helper'
require 'rake/testtask'

describe Bridge do
  after :each do
    Deja.neo.execute_script("g.clear()")
  end

  describe ".sane_hash" do
    context "given a hash returned from neo4j" do
      it "should return a hash capable of initializing a node" do

      end
    end
  end


  describe ".create_node" do
    context "with no attributes" do
      it "should raise an exception" do
        expect{Deja::Node.create_node()}.to raise_error(Deja::Error::NoParameter)
      end
    end

    context "with nil attribute" do
      it "should raise an exception" do
        expect{Deja::Node.create_node(nil)}.to raise_error(Deja::Error::InvalidParameter)
      end
    end

    context "with one attribute" do
      it "returns a node id" do
        response = Deja::Node.create_node(:name => 'Jerry Wang')
        response.should be_a_kind_of(Fixnum)
      end
    end

    context "with multiple attributes" do
      it "returns a node id" do
        response = Deja::Node.create_node(:name => 'Jerry Wang', :type => 'Person', :permalink => 'jerry_wang')
        response.should be_a_kind_of(Fixnum)
      end
    end
  end

  describe ".create_relationship" do
    before :each do
      @first_node = Deja::Node.create_node({:name => 'Jerry Wang'})
      @second_node = Deja::Node.create_node({:name => 'Harrison Ford'})
    end

    context "with no attributes" do
      it "returns a relationship id" do
        response = Deja::Node.create_relationship(@first_node, @second_node, :friends)
        response.should be_a_kind_of(Fixnum)
      end
    end
  end


  describe ".update_node_by_id" do
    before :each do

    end

    context "given an existing node id" do
      it "should return a response hash" do
        #response = Deja::update_node_by_id(@node)
      end
    end
  end

  describe ".get_single_node" do
    before :each do
      @node = Deja::Node.create_node({:name => 'get_single'})
    end

    context "given a node id" do
      it "should return a single node" do
        response = Deja::Node.get_single_node(@node)
        response.should be_a(Hash)
        response['data'].first.first['data']['name'].should eq('get_single')
      end

      it "should throw an error if node id doesn't exist" do
        expect{Deja::Node.get_single_node(@node + 5)}.to raise_error(Deja::Error::NodeDoesNotExist)
      end
    end
  end

  describe ".get_node_with_related_nodes" do
    before :each do
      @first_node = Deja::Node.create_node({:name => 'Jerry Wang'})
      @second_node = Deja::Node.create_node({:name => 'Harrison Ford'})
      @third_node = Deja::Node.create_node({:name => 'Mike Myers'})
      @first_relationship = Deja::Relationship.create_relationship(@first_node, @second_node, :friends)
      @second_relationship = Deja::Relationship.create_relationship(@first_node, @third_node, :enemies)
    end

    context "given a node id" do
      it "should return multiple nodes" do
        response = Deja::Node.get_node_with_related_nodes(@first_node)
        response.should be_a(Hash)
      end
    end
  end

  describe ".get_node_with_relationships" do
    before :each do
      @first_node = Deja::Node.create_node({:name => 'Jerry Wang'})
      @second_node = Deja::Node.create_node({:name => 'Harrison Ford'})
      @third_node = Deja::Node.create_node({:name => 'Mike Myers'})
      @first_relationship = Deja::Relationship.create_relationship(@first_node, @second_node, :friends)
      @second_relationship = Deja::Relationship.create_relationship(@first_node, @third_node, :enemies)
    end


  end

  describe ".get_single_relationship" do
    before :each do
      @first_node = Deja::Node.create_node({:name => 'Jerry Wang'})
      @second_node = Deja::Node.create_node({:name => 'Harrison Ford'})
      @relationship = Deja::Relationship.create_relationship(@first_node, @second_node, :friends)
    end

    context "given a relationship id" do
      it "should return a single relationship" do
        response = Deja::Relationship.get_single_relationship(@relationship)
        response.should be_a(Hash)
      end

      it "should throw an error if relationship id doesn't exist" do
        expect{Deja::Relationship.get_single_relationship(@relationship + 5)}.to raise_error(Deja::Error::RelationshipDoesNotExist)
      end
    end
  end

  describe ".delete_node" do
    before :each do
      @first_node = Deja::Node.create_node({:name => 'Jerry Wang'})
      @second_node = Deja::Node.create_node({:name => 'Harrison Ford'})
      @relationship = Deja::Relationship.create_relationship(@first_node, @second_node, :friends)
    end

    context "with relationships" do
      it "should delete the node and connecting relationships" do
        read_node = Deja::Node.get_single_node(@first_node)
        read_node.should be_a(Hash)
        read_rel = Deja::Relationship.get_single_relationship(@relationship)
        read_rel.should be_a(Hash)
        response = Deja::Node.delete_node(@first_node)
        expect{Deja::Node.get_single_node(@first_node)}.to raise_error(Deja::Error::NodeDoesNotExist)
        expect{Deja::Node.get_single_relationship(@relationship)}.to raise_error(Deja::Error::RelationshipDoesNotExist)
      end
    end
  end

  describe ".delete_relationship" do
    before :each do
      @first_node = Deja::Node.create_node({:name => 'Jerry Wang'})
      @second_node = Deja::Node.create_node({:name => 'Harrison Ford'})
      @relationship = Deja::Relationship.create_relationship(@first_node, @second_node, :friends)
    end

    context "given a relationship id" do
      it "should delete a single relationship" do
        read_rel = Deja::Relationship.get_single_relationship(@relationship)
        read_rel.should be_a(Hash)
        response = Deja::Node.delete_relationship(@relationship)
        expect{Deja::Node.get_single_relationship(@relationship)}.to raise_error(Deja::Error::RelationshipDoesNotExist)
      end

      it "should throw an error if relationship id doesn't exist" do
        expect{Deja::Relationship.get_single_relationship(@relationship + 5)}.to raise_error(Deja::Error::RelationshipDoesNotExist)
      end
    end
  end

end
