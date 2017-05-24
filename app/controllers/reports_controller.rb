class ReportsController < ApplicationController
  before_action :authorize_report
  skip_before_action :authorize_action

  def attendance_organization_size
    @attendance_organization_size_data = gather_report_data(:organization_size)
  end

  def attendance_years_of_experience
    @attendance_years_of_experience_data = gather_report_data(:years_of_experience)
  end

  def attendance_job_role
    @attendance_job_role_data = gather_report_data(:job_role)
  end

  def burnup_registrations
    @burnup_registrations_data = ReportService.instance.create_burnup_structure(@event)
  end

  private

  def authorize_report
    not_found unless can?(:read, ReportsController)
  end

  def gather_report_data(grouped_by)
    event.attendances.active.group(grouped_by).count.to_a.map { |x| x.map { |x_part| x_part || I18n.t('report.common.unknown') } }
  end
end