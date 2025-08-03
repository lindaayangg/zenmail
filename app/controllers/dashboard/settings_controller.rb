require "mini_magick"

class Dashboard::SettingsController < ApplicationController
  layout "with_navbar"
  before_action :require_login

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.errors.any?
      render :edit, status: :unprocessable_entity
      return
    end
    if @user.update(user_params)
      redirect_to dashboard_settings_path, notice: "Settings updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
