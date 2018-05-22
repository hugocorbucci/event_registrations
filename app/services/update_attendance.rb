# frozen_string_literal: true

class UpdateAttendance
  def self.run_for(update_params)
    event = update_params.event
    params = update_params.request_params
    attendance = Attendance.find(params[:id])
    attendance.update!(update_params.attributes_hash)
    attendance = PerformGroupCheck.run(attendance, params['registration_token'])
    attendance.registration_value = event.registration_price_for(attendance, update_params.payment_type_params)
    attendance.payment_type = update_params.payment_type_params
    attendance.save
    attendance
  end
end
