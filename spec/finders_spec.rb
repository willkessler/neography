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


describe Finders do
  after :each do
    Deja.neo.execute_script("g.clear()")
  end

  before :each do
    @first_node = FactoryGirl.create(:person);
    @second_node = FactoryGirl.create(:person);
    @third_node = FactoryGirl.create(:company);
    @invested_in = Deja::Relationship.create_relationship(@first_node.id, @second_node.id, :invested_in)
    @friends = Deja::Relationship.create_relationship(@first_node.id, @second_node.id, :friends)
    @hates = Deja::Relationship.create_relationship(@first_node.id, @third_node.id, :hates)
  end

  describe ".load_single" do
    context "given a node id and no filters" do
      before :each do
        @node = Person.load(@first_node.id)
      end

      it "should return a single node" do
        @node.name.should eq(@first_node.name)
        @node.permalink.should eq(@first_node.permalink)
        @node.should_not_receive(:load_related)
      end

      it "calling invested_in should call load_related" do
        @node.should_receive(:load_related).with(:invested_in)
        @node.invested_in
      end

      it "calling invested_in should return an array of relNodeWrappers" do
        @node.invested_in.should be_a(Array)
        @node.invested_in[0].should be_a(RelNodeWrapper)
      end
    end

    context "given a node id with an :invested_in argument" do
      it "should not call load_related when eager loading" do
        Person.load(@first_node.id, :include => :invested_in).should_not_receive(:load_related)
      end

      it "should return only the invested_in relationship" do
        first_node = Person.load(@first_node.id, :include => :invested_in)
        first_node.name.should eq(@first_node.name)
        first_node.permalink.should eq(@first_node.permalink)
        node_type_test(first_node, :invested_in)
      end
    end

    context "given a node id with an :invested_in and :friends argument" do
      it "should not call load_related when eager loading multiple relations" do
        first_node = Person.load(@first_node.id, :include => [:invested_in, :friends]).should_not_receive(:load_related)
      end

      it "should return both relationships" do
        first_node = Person.load(@first_node.id, :include => [:invested_in, :friends])
        first_node.name.should eq(@first_node.name)
        first_node.permalink.should eq(@first_node.permalink)
        node_type_test(first_node, :invested_in)
        node_type_test(first_node, :friends)
      end
    end

    context "given a node id with an :all filter" do
      it "should return a node and all related nodes" do
        first_node = Person.load(@first_node.id, :include => :all)
        first_node.invested_in.should_not be_nil
        first_node.friends.should_not be_nil
        first_node.hates.should_not be_nil
        full_node_type_test(first_node)
      end
    end
  end

  describe ".load" do
    context "given a node id with associated nodes" do
      it "should return node objects with relationships" do
        first_node = Person.load_many(@first_node.id)
        first_node.invested_in.should_not be_nil
        first_node.friends.should_not be_nil
        first_node.hates.should_not be_nil
        full_node_type_test(first_node)
      end
    end

    context "given multiple node ids" do
      it "should return an array of node objects and their relationships" do
        person_nodes = Person.load_many(@first_node.id, @second_node.id)
        person_nodes.should be_a(Array)
        person_nodes.each do |node|
          node.invested_in.should_not be_nil
          node.friends.should_not be_nil
        end
        person_nodes.first.hates.should_not be_nil
        full_node_type_test(person_nodes.first)
        person_nodes[1].hates.should be_nil
        person_nodes[0].name.should eq(@first_node.name)
        person_nodes[0].permalink.should eq(@first_node.permalink)
        person_nodes[1].name.should eq(@second_node.name)
        person_nodes[1].permalink.should eq(@second_node.permalink)
      end
    end
  end

  describe ".load_related" do
    context "on an instance of a single node" do
      before :each do
        @node = Person.load(@first_node.id)
      end

      it "should not call load_related on already loaded relations" do
        @node.invested_in
        @node.invested_in.should_not_receive(:load_related)
        @node.invested_in
      end

      it "should load all related nodes" do
        @node.load_related
        @node.invested_in.should be_a(Array)
        full_node_type_test(@node)
      end
    end
  end

end
