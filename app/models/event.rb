# == Schema Information
#
# Table name: events
#
#  allow_voting      :boolean
#  attendance_limit  :integer
#  created_at        :datetime
#  end_date          :datetime
#  full_price        :decimal(10, )
#  id                :integer          not null, primary key
#  link              :string(255)
#  location_and_date :string(255)
#  logo              :string(255)
#  name              :string(255)
#  price_table_link  :string(255)
#  start_date        :datetime
#  updated_at        :datetime
#

class Event < ActiveRecord::Base
  has_many :attendances
  has_many :registration_periods
  has_many :registration_quotas

  has_many :registration_groups

  has_and_belongs_to_many :organizers, class_name: 'User'

  validates :start_date, :end_date, :full_price, :name, presence: true

  scope :active_for, ->(date) { where('end_date > ?', date) }
  scope :not_started, -> { where('start_date > ?', Time.zone.today) }
  scope :ended, -> { where('end_date < ?', Time.zone.today) }

  def can_add_attendance?
    attendance_limit.nil? || attendance_limit == 0 || (attendance_limit > attendances.active.size)
  end

  def registration_price_for(attendance, payment_type)
    group = attendance.registration_group
    return group.amount if group.present? && group.amount.present? && group.amount > 0
    not_amounted_group(attendance, payment_type)
  end

  def period_for(today = Time.zone.today)
    registration_periods.for(today).first if registration_periods.present?
  end

  def find_quota
    registration_quotas.order(order: :asc).select(&:vacancy?)
  end

  def started
    Time.zone.today >= start_date
  end

  def add_organizer_by_email!(email)
    user = User.find_by(email: email)
    return false unless user.present? && (user.organizer? || user.admin?)
    organizers << user unless organizers.include?(user)
    save
  end

  private

  def not_amounted_group(attendance, payment_type)
    quota = find_quota
    value = extract_value(attendance, payment_type, quota)
    Money.new(value, :BRL)
  end

  def extract_value(attendance, payment_type, quota)
    if payment_type == Invoice::STATEMENT
      (full_price * 100)
    elsif period_for.present?
      period_for.price * attendance.discount
    elsif quota.first.present?
      quota.first.price * attendance.discount
    else
      (full_price * 100) * attendance.discount
    end
  end
end
