require 'spec_helper'
require 'deja/node'
require 'rake/testtask'

describe Bridge do
  before :each do
  end

  describe ".create_node" do
    context "with no attributes" do
      it "should raise an exception" do
        expect(Deja::Node.create_node()).to raise_error
      end
    end

    context "with nil attribute" do
      it "should raise an exception" do
        expect(Deja::Node.create_node(nil)).to raise_error
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

      it "returns a node id" do
        response = Deja::Node.create_relationship(@first_node['data'].first.first, @second_node['data'].first.first, :friends)
        response['data'].first.first.should be_a_kind_of(Fixnum)
      end
    end
  end

  describe ".get_all_related_nodes" do
    subject { node }

    context "with node id" do

    end
  end
end
