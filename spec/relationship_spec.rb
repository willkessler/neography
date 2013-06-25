require 'deja'
require 'spec_helper'
require 'rake/testtask'


describe Node do
  before :each do
    @first_node = FactoryGirl.create(:person);
    @second_node = FactoryGirl.create(:person);
    @relationship = Relationship.new(nil, :friends, @first_node, @second_node)
  end


  describe ".save" do
    context "with a relationship that has not yet been saved to the graph" do
      it "should create a new relationship in the graph" do
        @relationship.id.should be_nil
        @relationship.save
        @relationship.id.should be_a(Fixnum)
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
