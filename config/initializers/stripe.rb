# frozen_string_literal: true

require 'stripe'

Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key) || ENV['STRIPE_SECRET_KEY']
Stripe.api_version = '2023-10-16' # Use the latest stable version or your preferred version 