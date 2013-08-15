require 'deja'
require 'spec_helper'
require 'rake/testtask'

describe Node do
  before :each do
    @first_node = FactoryGirl.build(:person);
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
        @first_node.save.should be_true
        graph_node = Person.find_by_neo_id(id)
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
        expect{Person.find_by_neo_id(id)}.to raise_error()
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

  describe ".relationships" do
    context "with a node having relationships" do
      it "should return a list of relationships" do
        @first_node.relationships.should be_a(Hash)
      end
    end
  end

end
