class Admin::UsersController < Admin::BaseController
  def show
    @user = User.find(params[:id])
    @addresses = @user.addresses
    if @user.merchant?
      redirect_to admin_merchant_path(@user)
    end
  end

  def index
    @users = User.regular_users
  end

  def upgrade
    user = User.find(params[:id])
    user.update(role: "merchant")
    flash[:success] = "#{user.name} has been upgraded to a merchant"
    redirect_to admin_merchant_path(user)
  end
end
