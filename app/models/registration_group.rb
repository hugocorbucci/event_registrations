# frozen_string_literal: true

# == Schema Information
#
# Table name: registration_groups
#
#  amount                :decimal(10, )
#  automatic_approval    :boolean          default(FALSE)
#  capacity              :bigint(8)
#  created_at            :datetime
#  discount              :bigint(8)
#  event_id              :bigint(8)
#  id                    :bigint(8)        not null, primary key
#  leader_id             :bigint(8)
#  minimum_size          :bigint(8)
#  name                  :string(255)
#  paid_in_advance       :boolean          default(FALSE)
#  registration_quota_id :bigint(8)
#  token                 :string(255)
#  updated_at            :datetime
#

class RegistrationGroup < ApplicationRecord
  belongs_to :event
  belongs_to :leader, class_name: 'User', inverse_of: :led_groups
  belongs_to :registration_quota

  has_many :attendances, dependent: :restrict_with_error

  validates :event, :name, presence: true
  validates :capacity, :amount, presence: true, if: :paid_in_advance?
  validates :discount, numericality: { greater_than: 0 }, allow_nil: true
  validate :enough_capacity, if: :paid_in_advance?
  validate :discount_or_amount_present?

  before_create :generate_token

  def to_s
    name
  end

  def qtd_attendances
    attendances.active.count
  end

  def total_price
    attendances.active.sum(:registration_value)
  end

  def price?
    total_price.positive?
  end

  def leader_name
    leader&.full_name
  end

  def accept_members?
    true
  end

  def paid?
    attendances.map(&:paid?).any?
  end

  def free?
    discount == 100
  end

  def floor?
    minimum_size.to_i > 1
  end

  def incomplete?
    return false if minimum_size.blank?

    attendances.committed_to.count < minimum_size
  end

  def capacity_left
    return 0 if capacity.blank?

    capacity - attendances.active.count
  end

  def vacancies?
    return true if capacity.blank? || capacity.zero?

    capacity_left.positive?
  end

  private

  def generate_token
    self.token = SecureRandom.hex
  end

  def enough_capacity
    return if capacity.blank?

    if registration_quota.present? && registration_quota.capacity_left < capacity
      errors.add(:capacity, I18n.t('registration_group.quota_capacity_error'))
    elsif event.capacity_left < capacity
      errors.add(:capacity, I18n.t('registration_group.event_capacity_error'))
    end
  end

  def discount_or_amount_present?
    return true if discount.present? || amount.present?

    errors.add(:discount, I18n.t('registration_group.errors.discount_or_amount_present'))
    errors.add(:amount, I18n.t('registration_group.errors.discount_or_amount_present'))
  end
end
