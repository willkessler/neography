require 'deja'
require 'spec_helper'
require 'rake/testtask'

describe Query do
  after :each do
    Deja.neo.execute_query("START n=node(*) MATCH n-[r?]->() WHERE ID(n) <> 0 DELETE r DELETE n")
  end

  describe ".create_node" do
    context "with no attributes" do
      it "should raise an exception" do
        Deja::Query.create_node().should be_nil
      end
    end

    context "with nil attribute" do
      it "should raise an exception" do
        Deja::Query.create_node(nil).should be_nil
      end
    end

    context "with one attribute" do
      it "returns a node id" do
        response = Deja::Query.create_node(:name => 'Jerry Wang')
        response.should be_a_kind_of(Fixnum)
      end
    end

    context "with multiple attributes" do
      it "returns a node id" do
        response = Deja::Query.create_node(:name => 'Jerry Wang', :type => 'Person', :permalink => 'jerry_wang')
        response.should be_a_kind_of(Fixnum)
      end
    end
  end

  describe ".delete_node" do
    before :each do
      @first_node = Deja::Query.create_node({:name => 'Jerry Wang'})
      @second_node = Deja::Query.create_node({:name => 'Harrison Ford'})
      @relationship = Deja::Query.create_relationship(@first_node, @second_node, :friends)
    end

    context "with relationships" do
      it "should delete the node and connecting relationships" do
        first_node = Deja::Query.load_node(@first_node, :include => :none)
        first_node.should be_a(Array)
        first_rel = Deja::Query.load_relationship(@relationship)
        first_rel.should be_a(Array)
        response = Deja::Query.delete_node(@first_node)
        expect{Deja::Query.load_node(@first_node, :include => :none)}.to raise_error()
        expect{Deja::Query.load_relationship(@relationship)}.to raise_error()
      end
    end
  end

  describe ".update_node" do
    before :each do
      @first_node = Deja::Query.create_node({:name => 'Jerry Wang'})
    end

    context "given an existing node id" do
      it "should return true" do
        response = Deja::Query.update_node(@first_node, {:name => 'Manly Man'})
        response.should be_true
      end
    end

    context "given a non-existant node id" do
      it "should throw neography error" do
        expect{Deja::Query.update_node(6666666, {:name => 'Manly Man'})}.to raise_error(Neography::NotFoundException)
      end
    end
  end

  describe ".create_relationship" do
    before :each do
      @first_node = Deja::Query.create_node({:name => 'Jerry Wang'})
      @second_node = Deja::Query.create_node({:name => 'Harrison Ford'})
    end

    context "with no attributes" do
      it "returns a relationship id" do
        response = Deja::Query.create_relationship(@first_node, @second_node, :friends)
        response.should be_a_kind_of(Fixnum)
      end
    end
  end

  describe ".delete_relationship" do
    before :each do
      @first_node = Deja::Query.create_node({:name => 'Jerry Wang'})
      @second_node = Deja::Query.create_node({:name => 'Harrison Ford'})
      @relationship = Deja::Query.create_relationship(@first_node, @second_node, :friends)
    end

    context "given a relationship id" do
      it "should delete a single relationship" do
        first_rel = Deja::Query.load_relationship(@relationship)
        first_rel.should be_a(Array)
        response = Deja::Query.delete_relationship(@relationship)
        expect{Deja::Query.load_relationship(@relationship)}.to raise_error()
      end

      it "should throw an error if relationship id doesn't exist" do
        expect{Deja::Query.get_single_relationship(@relationship + 5)}.to raise_error()
      end
    end
  end

  describe ".load_node" do
    before :each do
      @first_node = Deja::Query.create_node({:name => 'Jerry Wang'})
      @second_node = Deja::Query.create_node({:name => 'Harrison Ford'})
      @third_node = Deja::Query.create_node({:name => 'Mike Myers'})
      @first_relationship = Deja::Query.create_relationship(@first_node, @second_node, :friends)
      @second_relationship = Deja::Query.create_relationship(@first_node, @third_node, :enemies)
    end

    it "should throw an error if node id doesn't exist" do
      expect{Deja::Query.load_node(10000)}.to raise_error()
    end

    context "given a node id, and argument :none" do
      it "should return a single node" do
        response = Deja::Query.load_node(@first_node)
        response.should be_a(Array)
        response.first[:name].should eq('Jerry Wang')
      end
    end

    context "given a node id, and argument :all" do
      it "should return multiple nodes" do
        response = Deja::Query.load_node(@first_node, :include => :all)
        response.should be_a(Array)
      end
    end
  end


  describe ".load_related_nodes" do
    before :each do
      @first_node = Deja::Query.create_node({:name => 'Jerry Wang'})
      @second_node = Deja::Query.create_node({:name => 'Harrison Ford'})
      @third_node = Deja::Query.create_node({:name => 'Mike Myers'})
      @first_relationship = Deja::Query.create_relationship(@first_node, @second_node, :friends)
      @second_relationship = Deja::Query.create_relationship(@first_node, @third_node, :enemies)
    end

    context "given a node id" do
      it "should return a hash" do
        response = Deja::Query.load_related_nodes(@first_node, :include => :all)
        response.should be_a(Hash)
      end
    end
  end
end


