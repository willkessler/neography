require 'deja'
require 'spec_helper'
require 'rake/testtask'

def full_node_type_test(node)
  node.should be_a(Node)
  node.class.relationships.each do |rel|
    node.send(rel).should be_a(Array)
    node.send(rel).each do |relnode|
      relnode.should be_a(RelNodeWrapper)
      relnode.node.should be_a(Node)
      relnode.rel.should be_a(Relationship)
    end
  end
end

def node_type_test(node, rel)
  node.should be_a(Node)
  node.send(rel).should be_a(Array)
  node.send(rel).each do |relnode|
    relnode.should be_a(RelNodeWrapper)
    relnode.node.should be_a(Node)
    relnode.rel.should be_a(Relationship)
  end
end

Deja.create_node_index('idx_Person')

class InvestedIn < Relationship; end
class Friends < Relationship; end
class Hates < Relationship; end

describe Finders do
  after :each do
    Deja.neo.execute_query("START n=node(*) MATCH n-[r?]->() WHERE ID(n) <> 0 DELETE r DELETE n")
  end

  before :each do
    @first_node = FactoryGirl.create(:person);
    @second_node = FactoryGirl.create(:person);
    @third_node = FactoryGirl.create(:company);
    @invested_in = Deja::Query.create_relationship(@first_node.id, @second_node.id, :invested_in)
    @friends = Deja::Query.create_relationship(@first_node.id, @second_node.id, :friends)
    @hates = Deja::Query.create_relationship(@first_node.id, @third_node.id, :hates)
  end

  describe ".find_by_neo_id" do
    context "given a node id and no filters" do
      before :each do
        @node = Person.find_by_neo_id(@first_node.id)
      end

      it "should return a node and all related nodes by default" do
        @node.should_not_receive(:related_nodes)
        @node.name.should eq(@first_node.name)
        @node.permalink.should eq(@first_node.permalink)
      end

      it "calling invested_in should not call related_nodes" do
        @node.should_not_receive(:related_nodes).with(:invested_in)
        @node.invested_in
      end

      it "calling invested_in should return an array of relNodeWrappers" do
        @node.invested_in.should be_a(Array)
        @node.invested_in[0].should be_a(RelNodeWrapper)
      end
    end

    context "given a node id with an :invested_in argument" do
      it "should not call related_nodes when eager loading" do
        Person.find_by_neo_id(@first_node.id, :include => :invested_in).should_not_receive(:related_nodes)
      end

      it "should return only the invested_in relationship" do
        first_node = Person.find_by_neo_id(@first_node.id, :include => :invested_in)
        first_node.name.should eq(@first_node.name)
        first_node.permalink.should eq(@first_node.permalink)
        node_type_test(first_node, :invested_in)
      end
    end

    context "given a node id with an :invested_in and :friends argument" do
      it "should not call related_nodes when eager loading multiple relations" do
        first_node = Person.find_by_neo_id(@first_node.id, :include => [:invested_in, :friends]).should_not_receive(:related_nodes)
      end

      it "should return both relationships" do
        first_node = Person.find_by_neo_id(@first_node.id, :include => [:invested_in, :friends])
        first_node.name.should eq(@first_node.name)
        first_node.permalink.should eq(@first_node.permalink)
        node_type_test(first_node, :invested_in)
        node_type_test(first_node, :friends)
      end
    end

    context "given a node id with a :none filter" do
      it "should return a node and no related nodes" do
        first_node = Person.find_by_neo_id(@first_node.id, :include => :none)
        first_node.should_receive(:related_nodes)
        first_node.invested_in
        full_node_type_test(first_node)
      end
    end
  end

  describe ".find" do
    context "given an index with associated nodes" do
      it "should return node objects with relationships" do
        first_node = Person.find_by_neo_id(@first_node.id)
        first_node.invested_in.should_not be_nil
        first_node.friends.should_not be_nil
        first_node.hates.should_not be_nil
        full_node_type_test(first_node)
      end
    end
  end

  describe ".related_nodes" do
    context "on an instance of a single node" do
      before :each do
        @node = Person.find_by_neo_id(@first_node.id)
      end

      it "should not call related_nodes on already loaded relations" do
        @node.should_not_receive(:related_nodes)
        @node.invested_in
      end

      it "should load all related nodes" do
        @node.related_nodes
        @node.invested_in.should be_a(Array)
        full_node_type_test(@node)
      end
    end
  end

  describe ".where" do
    context "given an indexed property" do
      it "should return a node with the given index" do
        @indexed_node = Person.where(:permalink, @first_node.permalink)
        @indexed_node.name.should eq(@first_node.name)
      end
    end
  end

  describe "in transactions" do
    context "updating multiple nodes" do
      before :each do
        @u_node1 = Person.find_by_neo_id(@first_node.id)
        @u_node2 = Person.find_by_neo_id(@second_node.id)
      end

      it "should do some shit" do
        @u_node1.name = "shark"
        @u_node2.name = "speak"

        Deja::Transaction.commit do
          @u_node1.save()
          @u_node2.save()
        end

        @u_node1_new = Person.find_by_neo_id(@first_node.id)
        @u_node2_new = Person.find_by_neo_id(@second_node.id)

        expect(@u_node1_new.name).to eq("shark")
        expect(@u_node2_new.name).to eq("speak")
      end

    end
  end

end
