class Company < Deja::Node
  attr_accessor :name, :permalink, :type
end

class Person < Deja::Node
  attr_accessor :name, :permalink, :type

  relationship :invested_in
  relationship :friends
  relationship :hates
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

