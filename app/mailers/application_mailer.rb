# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@agilebrazil.com'
  layout 'mailer'
end
