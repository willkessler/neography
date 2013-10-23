require 'deja'
require 'spec_helper'
require 'rake/testtask'

describe Bridge do
  after :each do
    Deja.neo.execute_query("START n=node(*) MATCH n-[r?]->() WHERE ID(n) <> 0 DELETE r DELETE n")
  end

  describe ".is_index" do
    context "given a hash" do
      it "should return true" do
        Deja::Bridge.is_index?({}).should be_true
      end
    end
  end

  describe ".cypher" do
    context "given a block of neo4j-cypher dsl" do
      it "should return a cypher result" do
        query = Deja::Bridge.cypher {node(1)}
        query.should be_a(Neo4j::Cypher::Result)
        query.to_s.should eq('START v1=node(1) RETURN v1')
      end
    end
  end

  describe ".create_node" do
    context "with no attributes" do
      it "should raise an exception" do
        expect{Deja::Bridge.create_node()}.to raise_error(Deja::Error::NoParameter)
      end
    end

    context "with nil attribute" do
      it "should raise an exception" do
        expect{Deja::Bridge.create_node(nil)}.to raise_error(Deja::Error::InvalidParameter)
      end
    end

    context "with one attribute" do
      it "returns a cypher result" do
        query = Deja::Bridge.create_node(:name => 'Jerry Wang')
        query.should be_a_kind_of(Neo4j::Cypher::Result)
      end
    end

    context "with multiple attributes" do
      it "returns a cypher result" do
        query = Deja::Bridge.create_node(:name => 'Jerry Wang', :type => 'Person', :permalink => 'jerry_wang')
        query.should be_a_kind_of(Neo4j::Cypher::Result)
      end
    end
  end

  describe ".delete_node" do
    context "given a node id" do
      it "should return cypher for deleting a node" do
        query = Deja::Bridge.delete_node(1)
        query.should be_a(Neo4j::Cypher::Result)
      end
    end
  end

  describe ".update_node_by_id" do
    context "given a node id" do
      it "should return a cypher result" do
        query = Deja::Bridge.update_node(1, {:some => :attr})
        query.should be_a(Neo4j::Cypher::Result)
      end
    end
  end

  describe ".create_relationship" do
    context "with no attributes" do
      it "returns a cypher result" do
        query = Deja::Bridge.create_relationship(1, 2, :friends, {:some => :attr})
        query.should be_a(Neo4j::Cypher::Result)
      end
    end
  end

  describe ".delete_relationship" do
    context "given a relationship id" do
      it "should return a cyphe result" do
        query = Deja::Bridge.delete_relationship(1)
        query.should be_a(Neo4j::Cypher::Result)
      end
    end
  end

  describe ".get_single_relationship" do
    context "given a relationship id" do
      it "should return a cypher result" do
        query = Deja::Bridge.get_relationship(1)
        query.should be_a(Neo4j::Cypher::Result)
      end
    end
  end

  describe ".get_related_nodes" do
    context "given a node id" do
      it "should return a cypher result" do
        query = Deja::Bridge.get_related_nodes(1, :include => :all)
        query.should be_a(Neo4j::Cypher::Result)
      end
    end
  end
end


