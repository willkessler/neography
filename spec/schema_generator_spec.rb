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

  it 'includes editable attributes' do
    Example.schema[:editable_attributes].size.should == 2
    Example.schema[:editable_attributes].should include(:name, :code)
  end

  it 'excludes non-editable attributes' do
    Example.schema[:editable_attributes].should_not include(:created_at)
  end
end

class Example < Deja::Node
  attribute :name, String
  attribute :code, String
  attribute :created_at, Time, :editable => false

  validates :name, :presence => true
  validates :code, :presence => true
  validates :code, :numericality => true
end
