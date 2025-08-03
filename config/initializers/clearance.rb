Clearance.configure do |config|
  config.routes = false
  config.redirect_url = "/dashboard"
  config.mailer_sender = Rails.application.credentials.dig(:app, :mailer_sender)
  config.rotate_csrf_on_sign_in = true
end
