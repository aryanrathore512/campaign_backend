FactoryBot.define do
  factory :template do
    title { Faker::Lorem.sentence(word_count: 3) }
    body { Faker::Lorem.paragraph(sentence_count: 2) }
  end
end
