require 'spec_helper'
require 'deja/node'
require 'rake/testtask'

describe Bridge do
  before :each do

  end

  describe ".create_node" do
    context "with one attribute" do
      it "returns a response hash" do
        response = Deja::Node.create_node({:name => 'Jerry Wang'})
        response.should be_a(Hash)
      end

      it "returns a node id" do
        response = Deja::Node.create_node({:name => 'Jerry Wang'})
        response['data'].first.first.should be_a_kind_of(Fixnum)
      end
    end
    # context 'when execute_query fails' do
    #   before :each do
    #     error_response = JSON.parse()
    #     Neography::Rest.any_instance.stub(:execute_query).and_return(nil)
    #   end

    #   it 'raises an exception' do
    #   end

    # end
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
