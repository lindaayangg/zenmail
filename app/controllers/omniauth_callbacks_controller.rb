# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  # Only require login for Facebook callback since it's for linking an existing account
  before_action :require_login, only: [ :facebook ]

  def google_oauth2
    # Google OAuth is for signing in, so we don't require login
    auth = request.env["omniauth.auth"]
    user = User.from_omniauth(auth)
    Rails.logger.info("GOOGLE AUTH PAYLOAD: #{auth.inspect}")

    if user.persisted?
      # Store Gmail OAuth tokens for email access
      expires_at = auth.credentials.expires_at ? Time.at(auth.credentials.expires_at) : nil

      user.update(
        access_token: auth.credentials.token,
        refresh_token: auth.credentials.refresh_token,
        token_expires_at: expires_at,
        provider: auth.provider,
        uid: auth.uid
      )

      sign_in user
      redirect_to dashboard_root_url, notice: "Successfully signed in with Google and connected your Gmail!"
    else
      redirect_to sign_in_url, alert: "Failed to sign in with Google."
    end
  end

  def facebook
    # Facebook OAuth is for linking an existing account, so we require login
    auth = request.env["omniauth.auth"]
    Rails.logger.info("FACEBOOK AUTH PAYLOAD: #{auth.inspect}")

    # Convert Unix timestamp to datetime if present
    expires_at = auth.credentials.expires_at ? Time.at(auth.credentials.expires_at) : nil

    success = current_user.update(
      facebook_uid: auth.uid,
      facebook_oauth_token: auth.credentials.token,
      facebook_oauth_token_expires_at: expires_at,
      facebook_name: auth.info.name,
      facebook_image_url: auth.info.image
    )

    # Fetch and save Facebook business info
    if success && current_user.facebook_oauth_token.present?
      begin
        graph = Koala::Facebook::API.new(current_user.facebook_oauth_token)
        pages = graph.get_connections("me", "accounts")
        if pages.present?
          current_user.update(facebook_business_info: pages.first)
        end
      rescue => e
        Rails.logger.error "Facebook API error (fetching business info): #{e.message}"
      end
    end

    if success
      redirect_to dashboard_channels_url, notice: "Successfully connected your Facebook account!"
    else
      redirect_to dashboard_channels_url, alert: "Failed to connect your Facebook account."
    end
  end

  def instagram
    # Instagram OAuth is for linking an existing account, so we require login
    auth = request.env["omniauth.auth"]
    Rails.logger.info("INSTAGRAM AUTH PAYLOAD: \\#{auth.inspect}")

    # Convert Unix timestamp to datetime if present
    expires_at = auth.credentials.expires_at ? Time.at(auth.credentials.expires_at) : nil

    success = current_user.update(
      instagram_uid: auth.uid,
      instagram_oauth_token: auth.credentials.token,
      instagram_oauth_token_expires_at: expires_at,
      instagram_name: auth.info.name,
      instagram_username: auth.info.nickname,
      instagram_image_url: auth.info.image,
    )

    # Fetch and save Instagram business info
    if success && current_user.instagram_oauth_token.present?
      begin
        uri = URI.parse("https://graph.instagram.com/me?fields=id,username,profile_picture_url,name,account_type&access_token=#{current_user.instagram_oauth_token}")
        response = Net::HTTP.get_response(uri)
        if response.is_a?(Net::HTTPSuccess)
          current_user.update(instagram_business_info: JSON.parse(response.body))
        else
          Rails.logger.error "Instagram API error (fetching business info): #{response.body}"
        end
      rescue => e
        Rails.logger.error "Instagram API error (fetching business info): #{e.message}"
      end
    end

    if success
      redirect_to dashboard_channels_url, notice: "Successfully connected your Instagram account!"
    else
      redirect_to dashboard_channels_url, alert: "Failed to connect your Instagram account."
    end
  end

  def failure
    redirect_to sign_in_url, alert: "Failed to sign in."
  end
end
