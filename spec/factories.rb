class Company < Deja::Node
  attribute :name, String
  attribute :permalink, String, :index => true
  attribute :type, String

  relationship :invested_in, :out => :investment, :in => :investor
end

class Person < Deja::Node
  attribute :name, String
  attribute :permalink, String, :index => true
  attribute :type, String
  attribute :age, Integer
  attribute :bank_balance, Float
  attribute :vip, Boolean
  attribute :tags, Hash
  attribute :born_on, Date
  attribute :knighted_at, Time

  relationship :invested_in, :out => :investment
  relationship :friends_with, :out => :friends
  relationship :has_hate, :out => :hates
  relationship :waits_for, :out => :waits
end


FactoryGirl.define do

  factory :entity do
    name { FactoryGirl.generate(:name) }
    permalink { FactoryGirl.generate(:permalink) }
  end

  factory :person, class: Person, parent: :entity do
    type 'Person'
  end

  factory :company, class: Company, parent: :entity do
    type 'Company'
  end

  sequence (:name)      { |n| "Name #{n}" }
  sequence (:permalink) { |n| "my_permalink_#{n}" }
end

