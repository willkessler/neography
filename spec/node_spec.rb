require 'deja'
require 'spec_helper'
require 'rake/testtask'
require 'benchmark'

def full_node_type_test(node)
  node.should be_a(Node)
  node.class.relationship_names.each do |k, v|
    node.send(v[:out_plural]).should be_a(Array)
    node.send(v[:out_plural]).each do |node|
      node.should be_a(Node)
    end
    node.send(:link, v[:out_plural]).each do |rel|
      rel.should be_a(Relationship)
    end
  end
end

def node_type_test(node, rel)
  node.should be_a(Node)
  node.send(rel).should be_a(Array)
  node.send(rel).each do |node|
    node.should be_a(Node)
  end
  node.send(:link, rel).should be_a(Array)
  node.send(:link, rel).each do |rel|
    rel.should be_a(Relationship)
  end
end

def build_nodes
  @first_node = FactoryGirl.build(:person);
  @second_node = FactoryGirl.build(:company);
end

class InvestedIn < Relationship; end
class FriendsWith < Relationship; end
class HasHate < Relationship; end

describe Node do
  after :each do
    Deja.neo.execute_query("START n=node(*) MATCH n-[r?]->() WHERE ID(n) <> 0 DELETE r DELETE n")
  end

  before :each do
    @first_node = FactoryGirl.create(:person);
    @second_node = FactoryGirl.create(:company);
    @third_node = FactoryGirl.create(:company);
    @invested_in = InvestedIn.new(@first_node, @second_node).create
    @friends = FriendsWith.new(@first_node, @second_node).create
    @hates = HasHate.new(@first_node, @third_node).create
    @hates2 = HasHate.new(@first_node, @second_node).create
  end

  describe ".find" do
    context "given a node id and no filters" do
      before :each do
        @node = Person.find(@first_node.id, :include => :all)
      end

      it "should return a node and all related nodes" do
        @node.should_not_receive(:related_nodes)
        @node.name.should eq(@first_node.name)
        @node.permalink.should eq(@first_node.permalink)
      end

      it "calling invested_in should call related_nodes" do
        @node.should_receive(:related_nodes).and_call_original
        @node.investment
      end

      it "calling invested_in should return an array of nodes" do
        @node.investments.should be_a(Array)
        @node.investments[0].should be_a(Company)
        @node.link(:investment).should be_a(Array)
      end
    end

    context "given a node id with an :invested_in argument" do
      it "should not call related_nodes when eager loading" do
        Person.find(@first_node.id, :include => :invested_in).should_not_receive(:related_nodes)
      end

      it "should return only the invested_in relationship" do
        first_node = Person.find(@first_node.id, :include => :invested_in)
        first_node.name.should eq(@first_node.name)
        first_node.permalink.should eq(@first_node.permalink)
        node_type_test(first_node, :investments)
      end
    end

    context "given a node id with an :invested_in and :friends argument" do
      it "should not call related_nodes when eager loading multiple relations" do
        first_node = Person.find(@first_node.id, :include => [:invested_in, :friends]).should_not_receive(:related_nodes)
      end

      it "should return both relationships" do
        first_node = Person.find(@first_node.id, :include => [:invested_in, :friends])
        first_node.name.should eq(@first_node.name)
        first_node.permalink.should eq(@first_node.permalink)
        node_type_test(first_node, :investments)
        node_type_test(first_node, :friends)
      end
    end

    context "given a node id with a :none filter" do
      it "should return a node and no related nodes" do
        first_node = Person.find(@first_node.id, :include => :none)
        first_node.should_receive(:related_nodes).at_least(:once).and_call_original
        full_node_type_test(first_node)
      end
    end

    context "given a neo_id with associated nodes and :all argument" do
      it "should return node objects with relationships" do
        first_node = Person.find(@first_node.id, :include => :all)
        first_node.investments.should_not be_nil
        first_node.friends.should_not be_nil
        first_node.hates.should_not be_nil
        full_node_type_test(first_node)
      end
    end

    context "given a node id and a select filter" do
      it "should return a node object with only the selected fields" do
        first_node = Person.find(@first_node.id, :include => :none, :select => [:name, :type])
        first_node.name.should_not be_nil
        first_node.permalink.should be_nil
      end
    end
  end

  describe ".related_nodes" do
    context "on an instance of a single node" do
      before :each do
        @node = Person.find(@first_node.id, :include => :none)
      end

      it "should call related_nodes on relations" do
        @node.should_receive(:related_nodes).and_call_original
        @node.investments(:filter => :person).each do |node, rel|
           node.should be_a(Node)
           rel.should be_a(Relationship)
        end
      end

      it "should load all related nodes" do
        @node.related_nodes
        @node.investment.should be_a(Node)
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

  describe ".save!" do
    context "with a node objec that ain't in the graph yet" do
      it "should return self" do
        @first_node.save!.should be_a(Person)
      end
    end
  end

  describe ".save" do
    before :each do
      build_nodes
    end
    context "with a node object which has not yet been saved to the graph" do
      it "should create a new node in the graph" do
        @first_node.id.should be_nil
        @first_node.save.should be_true
        @first_node.id.should_not be_nil
        @first_node.id.should be_a_kind_of(Fixnum)
      end
    end

    context "with a node object which already exists in the graph" do
      it "should update the node in the graph" do
        @first_node.save.should be_true
        id = @first_node.id
        @first_node.name = 'M'
        @first_node.save!
        @first_node.save.should be_true
        graph_node = Person.find(id)
        expect(graph_node.name).to eq('M')
      end
    end
  end

  describe ".destroy" do
    context "with a node which already exists in the graph" do
      it "should return a boolean" do
        @first_node.save
        @first_node.destroy.should be_true
      end
    end
  end

  describe ".delete" do
    before :each do
      build_nodes
    end
    context "with a node which already exists in the graph" do
      it "should delete the node from the graph" do
        @first_node.save.should be_true
        id = @first_node.id
        @first_node.delete.should be_true
        expect(@first_node.id).to be_nil
        expect{Person.find(id)}.to raise_error()
      end
    end

    context "with a node which doesn't already exist in the graph" do
      it "should do nothing" do
        id = @first_node.id
        @first_node.delete
        expect(@first_node.id).to eq(id)
      end
    end
  end

  describe ".count" do
    context "given a relationship alias that exists in graph and models" do
      it "should return an accurate count" do
        @first_node.count(:investments).should be(1)
      end
    end

    context "given a relationship alias that exists in models but not graph" do
      it "should return an accurate count" do
        @first_node.count(:waits).should be(0)
      end
    end

    context "given a relationship alias that is in neither models or graph" do
      it "should return false" do
        @first_node.count(:made_up_alias).should be_false
      end
    end
  end

  describe ".connections" do
    context "given a node with relationships" do
      it "should return an accurate count of all relationships" do
        @first_node.connections.should be 4
        @second_node.connections.should be 3
        @third_node.connections.should be 1
      end
    end
  end

  describe ".relationships" do
    context "with a node having relationships" do
      it "should return a list of relationships" do
        @first_node.relationships.should be_a(Hash)
      end
    end
  end

  describe "relationship filters and options" do
    before :each do
      @first_node.save()
      @second_node = FactoryGirl.create(:person);
      10.times do
        InvestedIn.new(@first_node, FactoryGirl.create(:company)).create
      end
      InvestedIn.new(@first_node, @second_node).create
    end

    context "given a filter" do
      it "should filter results" do
        @first_node.investments(:filter => :person).size.should be 1
      end
    end

    context "given an order" do
      it "should order results given capitals" do
        desc = @first_node.investments(:order => 'name DESC').collect {|node, rel| node.name }
        asc = @first_node.investments(:order => 'name ASC').collect {|node, rel| node.name }
        desc.should eq(asc.reverse)
      end

      it "should order results given lower case" do
        desc = @first_node.investments(:order => 'name desc').collect {|node, rel| node.name }
        asc = @first_node.investments(:order => 'name asc').collect {|node, rel| node.name }
        desc.should eq(asc.reverse)
      end
    end

    context "given a limit" do
      it "should limit results" do
        @first_node.investments(:limit => 2).size.should be 2
      end
    end

    context "given a offset" do
      it "should offset results" do
        @first_node.investments(:offset => 2).size.should be @first_node.count(:investments) - 2
      end
    end
  end

  describe "in batch" do
    context "with two nodes" do
      before :each do
        @first_node.save()
        @first_node = Person.find(@first_node.id)
        @second_node.save()
        @second_node = Person.find(@second_node.id)
      end

      it "should commit in single request" do
        @first_node.name = "shark"
        @second_node.name = "speak"

        Deja::Batch.commit do
          @first_node.save()
          @second_node.save()
        end

        @first_node_new = Person.find(@first_node.id)
        @second_node_new = Person.find(@second_node.id)

        expect(@first_node_new.name).to eq("shark")
        expect(@second_node_new.name).to eq("speak")
      end
    end
  end

  describe "auto indexing of nodes" do
    before :each do
      Deja.get_node_auto_index_properties.each do |index_property|
        Deja.remove_node_auto_index_property(index_property)
      end
      Deja.set_node_auto_index_status(false)
      @index_node = FactoryGirl.build(:person);
    end

    context "creating a node after auto index is set to true" do
      it "should add the node to the auto index" do
        Deja.set_node_auto_index_status(true)
        Deja.add_node_auto_index_property('name')
        @index_node.save()
        @grabit = Deja::Node.find({:index => 'node_auto_index', :key => 'name', :value => @index_node.name}, :include => :none)
        @grabit.id.should eq(@index_node.id)
      end
    end

    context "creating a node after index is created on two properties" do
      it "should allow queries across two keys" do
        Deja.set_node_auto_index_status(true)
        Deja.add_node_auto_index_property('name')
        Deja.add_node_auto_index_property('type')
        @index_node.save()
        @grabit = Deja::Node.find({:index => 'node_auto_index', :query => "name:\"#{@index_node.name}\" AND type: Person"}, :include => :none)
        @grabit.id.should eq(@index_node.id)
      end
    end
  end
end
