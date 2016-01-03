# == Schema Information
#
# Table name: attendances
#
#  id                     :integer          not null, primary key
#  event_id               :integer
#  user_id                :integer
#  registration_group_id  :integer
#  registration_date      :datetime
#  status                 :string(255)
#  email_sent             :boolean          default(FALSE)
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string(255)
#  last_name              :string(255)
#  email                  :string(255)
#  organization           :string(255)
#  phone                  :string(255)
#  country                :string(255)
#  state                  :string(255)
#  city                   :string(255)
#  badge_name             :string(255)
#  cpf                    :string(255)
#  gender                 :string(255)
#  twitter_user           :string(255)
#  address                :string(255)
#  neighbourhood          :string(255)
#  zipcode                :string(255)
#  notes                  :string(255)
#  event_price            :decimal(10, )
#  registration_quota_id  :integer
#  registration_value     :decimal(10, )
#  registration_period_id :integer
#  advised                :boolean          default(FALSE)
#  advised_at             :datetime
#  payment_type           :string(255)
#

class AttendancesController < ApplicationController
  before_filter :load_event, except: :index

  skip_before_filter :authorize_action, only: [:index]

  protect_from_forgery

  def index
    return unless can? :attendances_list, Attendance
    @attendances_list = event_for_index.attendances.search_for_list(params[:search], statuses_params)
    @pending_total = event_for_index.attendances.pending.count
    @accepted_total = event_for_index.attendances.accepted.count
    @paid_total = event_for_index.attendances.paid.count
    @cancelled_total = event_for_index.attendances.cancelled.count
    @total = event_for_index.attendances.count
    @total_without_cancelled = event_for_index.attendances.where.not(status: :cancelled).count
    respond_to do |format|
      format.html
      format.csv do
        send_data @attendances_list.to_csv, filename: 'attendances_list.csv'
      end
    end
  end

  def show
    @attendance = resource
    @invoice = Invoice.for_attendance(@attendance.id).first
    respond_to do |format|
      format.html
      format.json
    end
  end

  def destroy
    attendance = resource
    attendance.cancel

    redirect_to attendance_path(attendance)
  end

  def confirm
    attendance = resource
    begin
      attendance.confirm
    rescue => ex
      flash[:alert] = t('flash.attendance.mail.fail')
      Rails.logger.error('Airbrake notification failed. Logging error locally only')
      Rails.logger.error(ex.message)
    end

    redirect_to attendance_path(attendance)
  end

  def pay_it
    resource.pay
    responds_js
  end

  def accept_it
    resource.accept
    responds_js
  end

  def recover_it
    resource.recover
    redirect_to attendance_path(resource)
  end

  private

  def resource_class
    Attendance
  end

  def resource
    Attendance.find(params[:id])
  end

  def load_event
    @event = resource.event
  end

  def event_for_index
    @event ||= Event.includes(registration_periods: [:event]).find_by_id(params.require(:event_id))
  end

  def responds_js
    respond_to do |format|
      @attendance = resource
      format.js { render :attendance }
    end
  end

  def statuses_params
    statuses = []
    statuses << :pending if params[:pending].present?
    statuses << :accepted if params[:accepted].present?
    statuses += %i(paid confirmed) if params[:paid].present?
    # statuses << :confirmed if params[:paid].present?
    statuses << :cancelled if params[:cancelled].present?
    statuses
  end
end
