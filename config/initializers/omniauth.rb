# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
    Rails.application.credentials.dig(:google_oauth, :client_id),
    Rails.application.credentials.dig(:google_oauth, :client_secret),
    {
      scope: "email, profile, https://www.googleapis.com/auth/gmail.readonly, https://www.googleapis.com/auth/gmail.modify",
      prompt: "select_account",
      access_type: "offline"
    }

  provider :facebook,
    Rails.application.credentials.dig(:facebook_oauth, :app_id),
    Rails.application.credentials.dig(:facebook_oauth, :app_secret),
    {
      scope: "pages_manage_posts, pages_read_engagement, pages_show_list",
      config_id: Rails.application.credentials.dig(:facebook_oauth, :config_id)
    }

  provider :instagram,
    Rails.application.credentials.dig(:instagram_oauth, :app_id),
    Rails.application.credentials.dig(:instagram_oauth, :app_secret),
    scope: "instagram_business_basic"
end

OmniAuth.config.allowed_request_methods = %i[get]

OmniAuth.config.logger = Rails.logger
