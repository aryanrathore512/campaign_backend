FactoryBot.define do
  factory :campaign do
    name { "Test Campaign #{Faker::Number.unique.number(digits: 4)}" } # Ensure unique names
    campaign_type { "Email Campaign" }
    email_limit { Faker::Number.between(from: 1, to: 500) }
    start_time { Time.current }
    end_time { Time.current + 1.week }
    campaign_run_time { Faker::Number.between(from: 1, to: 24) }
    batch_contact { Faker::Number.between(from: 1, to: 50) }
    status { 'draft' }
  end
end
