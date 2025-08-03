class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.dig(:app, :mailer_sender)
  layout "mailer"
end
