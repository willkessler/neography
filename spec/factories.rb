

class Company < Deja::Node
  attribute :name, String
  attribute :permalink, String, :index => true
  attribute :type, String
end

class Person < Deja::Node
  attribute :name, String
  attribute :permalink, String, :index => true
  attribute :type, String

  relationships(:invested_in, :friends, :hates)
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

