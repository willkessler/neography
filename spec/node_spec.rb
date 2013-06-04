require 'deja'
require 'spec_helper'
require 'rake/testtask'

class Company < Deja::Node
  attr_accessor :name, :permalink
end

class Person < Deja::Node
  attr_accessor :name, :permalink

  relationship :Investments, :invested_in, 'Company'
end

describe Node do
  before :each do
    @person = Person.new()
    @person.name = 'Fred Astair'
    @person.permalink = 'fred_astair'
  end

  describe ".save" do
    context "with a node object which has not yet been saved to the graph" do
      it "should create a new node in the graph" do
        @person.id.should be_nil
        @person.save
        @person.id.should_not be_nil
        @person.id.should be_a_kind_of(Fixnum)
      end
    end

    context "with a node object which already exists in the graph" do
      it "should update the node in the graph" do
        @person.save
        old_id = @person.id
        @person.name = 'Mike Meyers'
        @person.save
        expect(@person.id).to eq(old_id)
        expect(@person.name).to eq('Mike Meyers')
      end
    end
  end

  describe ".delete" do
    context "with a node which already exists in the graph" do
      it "should delete the node from the graph" do
        @person.save
        old_id = @person.id
        @person.delete
        expect(@person.id).to be_nil
        expect{Person.load(old_id)}.to raise_error(Deja::Error::NodeDoesNotExist)
      end
    end
  end

end
