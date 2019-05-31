class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = "Welcome, #{@user.name}"
      redirect_to '/profile'
    else
      flash[:danger] = @user.errors.full_messages.join(". ")
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :address, :city, :state, :zip, :password, :password_confirmation)
  end
end
