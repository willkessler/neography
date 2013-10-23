require 'deja'
require 'spec_helper'
require 'rake/testtask'
require 'benchmark'

class InvestedIn < Relationship; end

describe Node do
  before :each do
    @first_node = FactoryGirl.build(:person);
    @second_node = FactoryGirl.build(:company);
  end

  describe ".save!" do
    context "with a node objec that ain't in the graph yet" do
      it "should return self" do
        @first_node.save!.should be_a(Person)
      end
    end
  end

  describe ".save" do
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
    before :each do
      @first_node.save()
      @second_node.save()
      @third_node = FactoryGirl.create(:company);
      @invested_in = InvestedIn.new(@first_node, @second_node).create
    end

    context "given a relationship alias that exists in graph and models" do
      it "should return an accurate count" do
        @first_node.count(:investments).should be(1)
      end
    end

    context "given a relationship alias that exists in models but not graph" do
      it "should return an accurate count" do
        @first_node.count(:hates).should be(0)
      end
    end

    context "given a relationship alias that is in neither models or graph" do
      it "should return false" do
        @first_node.count(:made_up_alias).should be_false
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
      it "should order results" do
        desc = @first_node.investments(:order => 'name DESC').collect {|node, rel| node.name }
        asc = @first_node.investments(:order => 'name ASC').collect {|node, rel| node.name }
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
end
