module Dashboard
  class SupportController < ApplicationController
    before_action :require_login
    layout "with_navbar"

    def index; end

    def new
      # For explicit new action if needed (optional, can use index)
    end

    def create
      @support_params = support_params
      if @support_params[:subject].blank? || @support_params[:message].blank?
        flash[:error] = "Subject and message are required."
        redirect_to dashboard_support_path(anchor: "contact-form") and return
      end
      SupportMailer.contact_support(current_user, @support_params).deliver_later
      flash[:success] = "Your message has been sent to support. We'll get back to you soon!"
      redirect_to dashboard_support_path(anchor: "contact-form")
    end

    private

    def support_params
      params.require(:support).permit(:subject, :message, :send_copy)
    end
  end
end
