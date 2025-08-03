module Dashboard
  class SubscriptionController < ApplicationController
    before_action :require_login
    layout "with_navbar"

    def index
      render :index
    end

    def create_checkout_session
      price_id = params[:price_id]

      # Validate presence of price_id
      unless price_id.present?
        render json: { error: "Missing required parameter: price_id" }, status: :bad_request and return
      end

      # Check if user is already subscribed to this price_id
      if current_user.subscription_plan == price_id
        render json: { error: "User is already subscribed to this plan." }, status: :unprocessable_entity and return
      end

      # Ensure the user has a Stripe customer ID
      unless current_user.stripe_customer_id
        customer = Stripe::Customer.create(email: current_user.email, name: current_user.name)
        current_user.update!(stripe_customer_id: customer.id)
      end

      session = Stripe::Checkout::Session.create(
        payment_method_types: [ "card" ],
        mode: "subscription",
        customer: current_user.stripe_customer_id,
        line_items: [
          {
            price: price_id,
            quantity: 1
          }
        ],
        success_url: dashboard_root_url + "?checkout=success",
        cancel_url: dashboard_subscription_url,
        client_reference_id: current_user.id
      )
      render json: { id: session.id }
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def billing_portal
      session = Stripe::BillingPortal::Session.create({
        customer: current_user.stripe_customer_id,
        return_url: dashboard_subscription_url
      })
      respond_to do |format|
        format.html { redirect_to session.url, allow_other_host: true }
        format.json { render json: { url: session.url } }
      end
    end
  end
end
