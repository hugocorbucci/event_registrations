# == Schema Information
#
# Table name: registration_quota
#
#  id                    :integer          not null, primary key
#  quota                 :integer
#  created_at            :datetime
#  updated_at            :datetime
#  event_id              :integer
#  registration_price_id :integer
#  order                 :integer
#  closed                :boolean          default(FALSE)
#  price_cents           :integer          default(0), not null
#  price_currency        :string           default("BRL"), not null
#

FactoryGirl.define do
  factory :registration_quota do
    event
    quota 25
    closed false
    price 40
  end
end
