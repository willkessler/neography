require 'spec_helper'
require 'deja/node'
require 'rake/testtask'

describe Bridge do
  before :each do

  end

  describe ".create_node" do
    context "with one attribute" do
      it "returns a json response" do
        json_response = Deja::Node.create_node({:name => 'Jerry Wang'})
        json_response.should not == nil
      end

      it "returns a node id" do
        json_response = Deja::Node.create_node({:name => 'Jerry Wang'})
        json_response['data'][0][0].should_be_an(Integer)
      end
    end
  end

  describe ".get_all_related_nodes" do
    subject { node }

    context "with node id" do

    end
  end
end
