FactoryBot.define do
  factory :subscription do
    account
    product
    number_of_licenses { 10 }
    issued_at { 1.month.ago }
    expires_at { 11.months.from_now }

    trait :expired do
      issued_at { 13.months.ago }
      expires_at { 1.month.ago }
    end

    trait :with_limited_licenses do
      number_of_licenses { 2 }
    end
  end
end
