# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_notifications
#
#  attendance_id   :bigint(8)        indexed
#  created_at      :datetime         not null
#  id              :bigint(8)        not null, primary key
#  notes           :text
#  params          :text
#  payer_email     :string(255)
#  settle_amount   :decimal(10, )
#  settle_currency :string(255)
#  status          :string(255)
#  transaction_id  :string(255)
#  updated_at      :datetime         not null
#
# Indexes
#
#  idx_4539845_index_payment_notifications_on_attendance_id  (attendance_id)
#
# Foreign Keys
#
#  fk_rails_2e64051bbf  (attendance_id => attendances.id) ON DELETE => restrict ON UPDATE => restrict
#

class PaymentNotification < ApplicationRecord
  belongs_to :attendance
  serialize :params

  after_create :mark_attendance_as_paid, if: ->(n) { n.status == 'Completed' }
  validates :attendance, presence: true

  scope :pag_seguro, -> { where('params LIKE ?', '%type: pag_seguro%') }
  scope :completed, -> { where(status: 'Completed') }

  def self.create_for_pag_seguro(params)
    attributes = from_pag_seguro_params(params)
    PaymentNotification.create!(attributes)
  end

  private

  def mark_attendance_as_paid
    if params[:store_code] == Figaro.env.pag_seguro_store_code
      attendance.paid!
    else
      Rollbar.log('error', "Failed Payment Notification for attendance: #{attendance.full_name}")
    end
  end

  class << self
    private

    def from_pag_seguro_params(params)
      PagSeguroService.config
      {
        params: params,
        attendance: Attendance.find(params[:pedido]),
        status: params[:status],
        transaction_id: params[:transaction_code],
        notes: params[:transaction_inspect]
      }
    end
  end
end
