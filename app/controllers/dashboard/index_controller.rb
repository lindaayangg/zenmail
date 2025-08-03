module Dashboard
  class IndexController < ApplicationController
    before_action :require_login
    layout "with_navbar"

    def index
      if params[:checkout] == "success"
        post_limit = current_user.post_limit
        plan_name = current_user.subscription_plan_name
        if plan_name.present? and post_limit.present?
          flash.now[:success] = "Thank you for subscribing to the #{plan_name} plan! You can now create up to #{post_limit} posts per month."
        end
      end
    end
  end
end
