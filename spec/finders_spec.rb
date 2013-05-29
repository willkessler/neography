require 'deja'
require 'spec_helper'
require 'rake/testtask'

class Person < Deja::Node
  attr_accessor :name, :permalink
end

describe Finders do

  describe ".load" do
    before :each do
      @node = Deja::Node.create_node(:name => 'Jerry Wang', :permalink => 'jerry_wang')

    end

    context "given a node id" do
      it "should return a node object populated with graph data" do
        person_node = Person.load(@node['data'].first.first)
        puts person_node.name
      end
    end
  end

end
