class UsersController < Clearance::UsersController
  private

  def user_from_params
    user_params = params.require(:user).permit(:email, :password, :name, :phone_number, :phone_country_code)
    Clearance.configuration.user_model.new(user_params)
  end
end
