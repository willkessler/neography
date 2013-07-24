require 'spec_helper'

describe Deja::SchemaGenerator do
  it 'includes attributes' do
    Example.schema.should have_key :attributes
  end

  it 'includes attributes types' do
    Example.schema[:attributes][:name].should be_a(Hash)
    Example.schema[:attributes][:code].should be_a(Hash)
  end

  it 'includes validations' do
    Example.schema.should have_key :validations
  end

  it 'includes validations details' do
    Example.schema[:validations][:name].should == { :presence => {} }
    Example.schema[:validations][:code].should == { :presence => {}, :numericality => {} }
  end

  it 'groups validations by attribute' do
    Example.schema[:validations].keys.size.should == 2
    Example.schema[:validations].should have_key :name
    Example.schema[:validations].should have_key :code
  end

  it 'groups validators by kind' do
    Example.schema[:validations][:code].keys.size.should == 2
    Example.schema[:validations][:code].should have_key :presence
    Example.schema[:validations][:code].should have_key :numericality
  end
end

class Example < Deja::Node
  attribute :name, String
  attribute :code, String

  validates :name, :presence => true
  validates :code, :presence => true
  validates :code, :numericality => true
end
