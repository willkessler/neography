require 'deja'
require 'spec_helper'
require 'rake/testtask'

class Friends < Relationship
  attribute :uuid, Integer
  attribute :name, String
end

describe Node do
  before :each do
    @first_node = FactoryGirl.create(:person);
    @second_node = FactoryGirl.create(:person);

    @relationship_properties = {:uuid => rand(100), :name => "FooBar"}
    @relationship = Friends.new(:friends, @first_node, @second_node, :out, @relationship_properties)
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
end
