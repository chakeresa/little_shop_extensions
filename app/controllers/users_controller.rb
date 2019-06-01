class UsersController < ApplicationController

  def new
    @user = User.new
    @user.addresses.build
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @address = Address.new(address_params(@user))
      if @address.save
        @user.update(primary_address: @address)
        session[:user_id] = @user.id
        flash[:success] = "Welcome, #{@user.name}"
        redirect_to '/profile'
      else
        flash[:danger] = @address.errors.full_messages.join(". ")
        render :new
      end
    else
      flash[:danger] = @user.errors.full_messages.join(". ")
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :address, :city, :state, :zip, :password, :password_confirmation)
  end

  def address_params(user)
    altered_params = params.require(:user).require(:addresses_attributes).require("0").permit(:street, :city, :state, :zip)
    altered_params[:user] = user
    altered_params
  end
end
