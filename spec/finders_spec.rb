require 'deja'
require 'spec_helper'
require 'rake/testtask'

class Company < Deja::Node
  attr_accessor :name, :permalink, :type
end

class Person < Deja::Node
  attr_accessor :name, :permalink, :type

  relationship :invested_in
end

describe Finders do
  describe ".load" do
    before :each do
      @node = Deja::Node.create_node(:name => 'Jerry Wang', :permalink => 'jerry_wang', :type => 'Person')
      @second_node = Deja::Node.create_node(:name => 'Willy Wonka', :permalink => 'willy_wonka', :type => 'Person')
      @third_node = Deja::Node.create_node(:name => 'Fuck tha police', :permalink => 'f_police', :type => 'Company')
      @relationship = Deja::Relationship.create_relationship(@node, @second_node, :invested_in)
      @other_relationship = Deja::Relationship.create_relationship(@node, @third_node, :friends)
    end

    context "given a single node id" do
      it "should return a node object" do
        person_node = Person.load(@node)
        person_node.id.should eq(@node)
        expect(person_node.name).to eq('Jerry Wang')
        expect(person_node.permalink).to eq('jerry_wang')
      end
    end

    context "given a node id with associated nodes" do
      it "should return node objects with relationships" do
        person_node = Person.load(@node)
        person_node.invested_in.should be_a(Array)
        person_node.invested_in.each do |investment|
          investment.should be_a(RelNodeWrapper)
          investment.node.should be_a(Node)
          investment.rel.should be_a(Relationship)
        end
      end
    end

    context "given multiple node ids" do
      it "should return an array of node objects and their relationships" do
        person_nodes = Person.load(@node, @second_node)
        person_nodes.should be_a(Array)
        person_nodes.each do |node|
          node.should be_a(Node)
          node.invested_in.should be_a(Array)
          node.invested_in.each do |investment|
            investment.should be_a(RelNodeWrapper)
            investment.node.should be_a(Node)
            investment.rel.should be_a(Relationship)
          end
        end
        person_nodes[0].id.should eq(@node)
        person_nodes[0].name.should eq('Jerry Wang')
        person_nodes[1].id.should eq(@second_node)
        person_nodes[1].name.should eq('Willy Wonka')
      end
    end
  end
end
