FactoryBot.define do
  factory :filming_location do
    name { Faker::Address.city }
  end
end 