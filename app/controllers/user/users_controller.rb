class User::UsersController < User::BaseController
  def show
    @user_orders = current_user.orders
  end

  def edit
  end

  def update
    if current_user.email != params[:email].downcase && User.find_by(email: params[:email].downcase)
      flash[:danger] = "That email address is already in use"
      redirect_to profile_edit_path
      return
    else
      attempt_update
    end
  end

  private

  def update_params
    altered_params = params.permit(:name, :email, :address, :city, :state, :zip, :password, :password_confirmation)

    if params[:password] == "" || params[:password_confirmation] == ""
      altered_params = altered_params.except(:password).except(:password_confirmation)
    end

    altered_params
  end

  def attempt_update
    if current_user.update(update_params.to_h)
      flash[:success] = "Your profile has been updated"
      redirect_to profile_path
    else
      flash[:danger] = current_user.errors.full_messages.join(". ")
      redirect_to profile_edit_path
      return
    end
  end
end
