

class Company < Deja::Node
  attribute :name, String
  attribute :permalink, String, :index => true
  attribute :type, String

  relationship :invested_in, :as => :investment, :reverse => :investor
end

class Person < Deja::Node
  attribute :name, String
  attribute :permalink, String, :index => true
  attribute :type, String

  relationship :invested_in, :as => :investment
  relationship :friends_with, :as => :friends
  relationship :has_hate, :as => :hates
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

