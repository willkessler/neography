require 'deja'
require 'spec_helper'
require 'rake/testtask'

class FriendsWith < Relationship
  attribute :uuid, Integer
  attribute :name, String
end

describe Node do
  before :each do
    @first_node = FactoryGirl.create(:person);
    @second_node = FactoryGirl.create(:person);

    @relationship_properties = {:uuid => rand(100), :name => "FooBar"}
    @relationship = FriendsWith.new(:friends_with, @first_node, @second_node, :out, @relationship_properties)
  end

  describe ".save" do
    context "with a relationship that has not yet been saved to the graph" do
      it "should create a new relationship in the graph" do
        @relationship.id.should be_nil
        @relationship.save

        @relationship.id.should be_a(Fixnum)
      end

      it "should set properties on relationship in the graph" do
        @relationship.save

        @relationship_properties.each do |key, value|
          @relationship.send(key).should == value
        end
      end
    end
  end

  describe ".delete" do
    context "with a relationship that already exists in the graph" do
      it "should delete the relationship from the graph" do
        @relationship.save
        @relationship.delete
        @relationship.id.should be_nil
      end
    end
  end

  describe ".find" do
    context "given a relationship id which exists in the graph" do
      it "should return a relationship object with related nodes" do
        @relationship.save
        new_rel = FriendsWith.find(@relationship.id)
        new_rel.should be_a(Relationship)
        new_rel.start_node.should be_a(Node)
        new_rel.end_node.should be_a(Node)
      end
    end
  end
end
