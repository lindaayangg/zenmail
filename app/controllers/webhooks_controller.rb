class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  # Stripe webhook endpoint
  def stripe
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

    Rails.logger.info "Stripe webhook received: #{request.headers['HTTP_STRIPE_SIGNATURE']}"
    Rails.logger.debug "Payload: #{payload}"

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      Rails.logger.error "Stripe webhook JSON parse error: #{e.message}"
      render json: { error: "Invalid payload" }, status: 400 and return
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "Stripe webhook signature verification error: #{e.message}"
      render json: { error: "Invalid signature" }, status: 400 and return
    end

    Rails.logger.info "Stripe event type: #{event['type']}"

    case event["type"]
    when "checkout.session.completed"
      session = event["data"]["object"]
      Rails.logger.info "Handling checkout.session.completed for session: #{session['id']}"
      handle_checkout_session_completed(session)
    when "customer.subscription.updated", "customer.subscription.created"
      subscription = event["data"]["object"]
      Rails.logger.info "Handling subscription update for subscription: #{subscription['id']}"
      handle_subscription_update(subscription)
    when "customer.subscription.deleted"
      subscription = event["data"]["object"]
      Rails.logger.info "Handling subscription deleted for subscription: #{subscription['id']}"
      handle_subscription_deleted(subscription)
    else
      Rails.logger.info "Unhandled Stripe event type: #{event['type']}"
    end

    render json: { status: "success" }
  end

  private

  def handle_checkout_session_completed(session)
    user = User.find_by(id: session["client_reference_id"])
    Rails.logger.info "Checkout session completed for user_id: #{session['client_reference_id']} (found: #{user.present?})"
    return unless user
    Rails.logger.info "Updating user #{user.id} with stripe_customer_id: #{session['customer']} and stripe_price_id: #{session['display_items']&.first&.dig('price', 'id') || session['subscription']}"
    user.update(
      stripe_customer_id: session["customer"],
      stripe_price_id: session["display_items"]&.first&.dig("price", "id") || session["subscription"],
    )
  end

  def handle_subscription_update(subscription)
    user = User.find_by(stripe_customer_id: subscription["customer"])
    Rails.logger.info "Subscription update for customer: #{subscription['customer']} (user found: #{user.present?})"
    return unless user

    # Safely get current_period_end from top-level or from items["data"][0]
    current_period_end_value = subscription["current_period_end"]
    if current_period_end_value.nil? && subscription["items"] && subscription["items"]["data"] && subscription["items"]["data"].any?
      current_period_end_value = subscription["items"]["data"][0]["current_period_end"]
    end
    current_period_end = Time.at(current_period_end_value).to_datetime if current_period_end_value

    price_id = nil
    if subscription["items"] && subscription["items"]["data"] && subscription["items"]["data"].any?
      price_id = subscription["items"]["data"][0]["price"]["id"] rescue nil
    end
    subscription_id = subscription["id"]
    status = subscription["status"]
    trial_end = subscription["trial_end"]

    Rails.logger.info "Updating user #{user.id} with price_id: #{price_id}, subscription_id: #{subscription_id}, subscription_expires_at: #{current_period_end}, status: #{status}"

    update_attrs = {
      stripe_price_id: price_id,
      stripe_subscription_id: subscription_id,
      subscription_expires_at: current_period_end
    }

    if status == "trialing"
      update_attrs[:stripe_trial_ends_at] = trial_end ? Time.at(trial_end).to_datetime : nil
    else
      update_attrs[:stripe_trial_ends_at] = nil
    end

    user.update(update_attrs)
  end

  def handle_subscription_deleted(subscription)
    user = User.find_by(stripe_customer_id: subscription["customer"])
    Rails.logger.info "Subscription deleted for customer: #{subscription['customer']} (user found: #{user.present?})"
    return unless user
    Rails.logger.info "Clearing subscription_expires_at, subscription_id, and trial_ends_at for user #{user.id}"
    user.update(
      stripe_price_id: nil,
      stripe_subscription_id: nil,
      subscription_expires_at: nil,
      stripe_trial_ends_at: nil,
    )
  end
end
