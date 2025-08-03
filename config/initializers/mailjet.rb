# frozen_string_literal: true

Mailjet.configure do |config|
  config.api_key = Rails.application.credentials.dig(:mailjet, :api_key)
  config.secret_key = Rails.application.credentials.dig(:mailjet, :secret_key)
  config.default_from = Rails.application.credentials.dig(:app, :mailer_sender)
  config.api_version = "v3.1"
end
