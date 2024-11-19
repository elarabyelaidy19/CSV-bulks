FactoryBot.define do
  factory :review do
    movie
    user
    rating { rand(1..5) }
    comment { Faker::Lorem.paragraph }
  end
end 