require 'deja'
require 'spec_helper'
require 'rake/testtask'

describe Bridge do
  before :each do
  end

  describe ".create_node" do
    context "with no attributes" do
      it "should raise an exception" do
        expect{Deja::Node.create_node()}.to raise_error(Deja::Error::NoParameter)
      end
    end

    context "with nil attribute" do
      it "should raise an exception" do
        expect{Deja::Node.create_node(nil)}.to raise_error(Deja::Error::InvalidParameter)
      end
    end

    context "with one attribute" do
      it "returns a response hash" do
        response = Deja::Node.create_node(:name => 'Jerry Wang')
        response.should be_a(Hash)
      end

      it "returns a node id" do
        response = Deja::Node.create_node(:name => 'Jerry Wang')
        response['data'].first.first.should be_a_kind_of(Fixnum)
      end
    end

    context "with multiple attributes" do
      it "returns a response hash" do
        response = Deja::Node.create_node(:name => 'Jerry Wang', :type => 'Person', :permalink => 'jerry_wang')
        response.should be_a(Hash)
      end
      it "returns a node id" do
        response = Deja::Node.create_node(:name => 'Jerry Wang', :type => 'Person', :permalink => 'jerry_wang')
        response['data'].first.first.should be_a_kind_of(Fixnum)
      end
    end
  end

  describe ".create_relationship" do
    before :each do
      @first_node = Deja::Node.create_node({:name => 'Jerry Wang'})
      @second_node = Deja::Node.create_node({:name => 'Harrison Ford'})
    end

    context "with no attributes" do
      it "returns a response hash" do
        response = Deja::Node.create_relationship(@first_node['data'].first.first, @second_node['data'].first.first, :friends)
        response.should be_a(Hash)
      end

      it "returns a relationship id" do
        response = Deja::Node.create_relationship(@first_node['data'].first.first, @second_node['data'].first.first, :friends)
        response['data'].first.first.should be_a_kind_of(Fixnum)
      end
    end
  end


  describe ".delete_node" do
    before :each do
      @first_node = Deja::Node.create_node({:name => 'Jerry Wang'})
      @second_node = Deja::Node.create_node({:name => 'Harrison Ford'})
      @relationship = Deja::Relationship.create_relationship(@first_node['data'].first.first, @second_node['data'].first.first, :friends)
    end

    context "with relationships" do
      it "should delete the node and connecting relationships" do
        read_node = Deja::Node.get_single_node(@first_node['data'].first.first)
        read_node.should be_a(Hash)
        read_rel = Deja::Relationship.get_single_relationship(@relationship['data'].first.first)
        read_rel.should be_a(Hash)
        response = Deja::Node.delete_node(@first_node['data'].first.first)
        expect{Deja::Node.get_single_node(@first_node['data'].first.first)}.to raise_error(Deja::Error::NodeDoesNotExist)
        expect{Deja::Node.get_single_relationship(@relationship['data'].first.first)}.to raise_error
      end
    end
  end


end
