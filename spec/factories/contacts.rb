FactoryBot.define do
  factory :contact do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    address { Faker::Address.full_address }
    age { rand(18..65) }
  end
end
