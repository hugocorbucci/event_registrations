FactoryGirl.define do
  factory :registration_quota do
    event
    registration_price
    quota 25
    closed false
  end
end