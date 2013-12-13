require 'deja'
require 'spec_helper'
require 'rake/testtask'

describe TypeCaster do
  let(:person) { FactoryGirl.build(:person) }

  context 'typecast' do
    it 'should typecast a valid string' do
      person.name = 'james bond'
      expect(person.name).to eq('james bond')
    end

    it 'should typecast a valid integer' do
      person.age = '-5'
      expect(person.age).to eq(-5)

      person.age = 10
      expect(person.age).to eq(10)
    end

    it 'should fail to cast an invalid integer' do
      expect { person.age = '5a' }.to raise_error
    end

    it 'should cast a valid float' do
      person.bank_balance = 50000.51
      expect(person.bank_balance).to eq(50000.51)

      person.bank_balance = '10.25'
      expect(person.bank_balance).to eq(10.25)
    end

    it 'should fail to cast an invalid floating point value' do
      expect { person.bank_balance = '5a' }.to raise_error
    end

    it 'should cast a valid boolean value' do
      person.vip = 'true'
      expect(person.vip).to eq(true)

      person.vip = 't'
      expect(person.vip).to eq(true)

      person.vip = true
      expect(person.vip).to eq(true)

      person.vip = 1
      expect(person.vip).to eq(true)

      person.vip = 'false'
      expect(person.vip).to eq(false)

      person.vip = 'f'
      expect(person.vip).to eq(false)

      person.vip = false
      expect(person.vip).to eq(false)

      person.vip = 0
      expect(person.vip).to eq(false)
    end

    it 'should fail to cast an invalid boolean value' do
      expect { person.vip = 'tru1' }.to raise_error TypeError
    end

    it 'should fail on unrecognized data type' do
      expect { person.tags = ['engineer', 'designer', 'entrepreneur'] }.to raise_error TypeError
    end
  end
end
