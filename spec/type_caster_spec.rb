require 'deja'
require 'spec_helper'
require 'rake/testtask'

describe TypeCaster do
  let(:person) { FactoryGirl.build(:person) }

  context 'typecast' do
    it 'should typecast a valid string' do
      person.name = 'james bond'
      expect(TypeCaster.typecast(:name, person.name, 'Person')).to eq('james bond')
    end

    it 'should typecast a valid integer' do
      person.age = '-5'
      expect(TypeCaster.typecast(:age, person.age, 'Person')).to eq(-5)

      person.age = 10
      expect(TypeCaster.typecast(:age, person.age, 'Person')).to eq(10)
    end

    it 'should fail to cast an invalid integer' do
      expect(TypeCaster.typecast(:age, person.age, 'Person')).to raise_error
    end

    it 'should cast a valid float' do
      person.bank_balance = 50000.51
      expect(TypeCaster.typecast(:bank_balance, person.bank_balance, 'Person')).to eq(50000.51)

      person.bank_balance = '10.25'
      expect(TypeCaster.typecast(:bank_balance, person.bank_balance, 'Person')).to eq(10.25)
    end

    it 'should fail to cast an invalid floating point value' do
      expect{TypeCaster.typecast(:bank_balance, '5a', 'Person')}.to raise_error
    end

    it 'should cast a valid boolean value' do
      person.vip = 'true'
      expect(TypeCaster.typecast(:vip, person.vip, 'Person')).to eq(true)

      person.vip = 't'
      expect(TypeCaster.typecast(:vip, person.vip, 'Person')).to eq(true)

      person.vip = true
      expect(TypeCaster.typecast(:vip, person.vip, 'Person')).to eq(true)

      person.vip = 1
      expect(TypeCaster.typecast(:vip, person.vip, 'Person')).to eq(true)

      person.vip = 'false'
      expect(TypeCaster.typecast(:vip, person.vip, 'Person')).to eq(false)

      person.vip = 'f'
      expect(TypeCaster.typecast(:vip, person.vip, 'Person')).to eq(false)

      person.vip = false
      expect(TypeCaster.typecast(:vip, person.vip, 'Person')).to eq(false)

      person.vip = 0
      expect(TypeCaster.typecast(:vip, person.vip, 'Person')).to eq(false)
    end

    it 'should fail to cast an invalid boolean value' do
      expect { TypeCaster.typecast(:vip, 'tru1', 'Person') }.to raise_error TypeError
    end

    it 'should fail on unrecognized data type' do
      expect { TypeCaster.typecast(:tags, ['engineer', 'designer', 'entrepreneur'], 'Person') }.to raise_error TypeError
    end

    it 'should validate date values' do
      Timecop.freeze do
        person.born_on = Date.today
        expect(person.instance_variable_get("@born_on")).to eq(Date.today)
        expect(person.born_on).to eq(Date.today)
      end
    end

    it 'should validate time values' do
      Timecop.freeze do
        person.knighted_at = Time.now
        expect(person.instance_variable_get("@knighted_at")).to eq(Time.now)
        expect(person.knighted_at.to_i).to eq(Time.now.to_i)
      end
    end
  end
end
