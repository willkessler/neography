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



describe Finders do

  describe ".load" do
    before :each do
      @node = Deja::Node.create_node(:name => 'Jerry Wang', :permalink => 'jerry_wang')
      @second_node = Deja::Node.create_node(:name => 'Willy Wonka', :permalink => 'willy_wonka')
      @third_node = Deja::Node.create_node(:name => 'Fuck tha police', :permalink => 'f_police')
      @relationship = Deja::Relationship.create_relationship(@node['data'].first.first, @second_node['data'].first.first, :invested_in)
      @other_relationship = Deja::Relationship.create_relationship(@node['data'].first.first, @third_node['data'].first.first, :friends)
    end

    context "given a single node id" do
      it "should return a node object" do
        person_node = Person.load(@node['data'].first.first)
        person_node.id.should eq(@node['data'].first.first)
        person_node.name.should eq('Jerry Wang')
        person_node.permalink.should eq('jerry_wang')
      end
    end

    context "given a node id with associated nodes" do
      it "should return node objects with relationships" do
        person_node = Person.load(@node['data'].first.first)
        puts person_node.relationships
      end
    end

    context "given multiple node ids" do
      it "should return an array of node objects" do
        person_nodes = Person.load(@node['data'].first.first, @second_node['data'].first.first)
        person_nodes.should be_a(Array)
        person_nodes[0].id.should eq(@node['data'].first.first)
        person_nodes[0].name.should eq('Jerry Wang')
        person_nodes[0].permalink.should eq('jerry_wang')
        person_nodes[1].id.should eq(@second_node['data'].first.first)
        person_nodes[1].name.should eq('Willy Wonka')
        person_nodes[1].permalink.should eq('willy_wonka')
      end
    end
  end

end
