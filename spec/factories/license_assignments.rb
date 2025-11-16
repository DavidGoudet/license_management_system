FactoryBot.define do
  factory :license_assignment do
    account
    user
    product

    trait :with_subscription do
      after(:build) do |assignment|
        create(:subscription,
                account: assignment.account,
                product: assignment.product,
                number_of_licenses: 10)
      end
    end
  end
end
