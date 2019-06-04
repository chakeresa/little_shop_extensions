class User::AddressesController < User::BaseController
  def new
    @user = current_user
    @address = Address.new
  end

  def create
    @address = Address.new(address_params)
    if @address.save
      flash[:success] = "Added \"#{@address.nickname}\" address"
      redirect_to profile_path
    else
      flash[:danger] = @address.errors.full_messages.join(". ")
      @user = current_user
      render :new
    end
  end

  def edit
    @user = current_user
    @address = Address.find(params[:id])
  end

  def update
  end

  def destroy
    address = Address.find(params[:id])
    if address.user_id == current_user.id
      if address.no_completed_orders?
        nickname = address.nickname
        address.delete_addr_and_associations
        flash[:success] = "#{nickname.titlecase} address has been deleted"
        redirect_to profile_path
        return
      else
        flash[:danger] = "Cannot delete an address that was used for packaged/shipped order(s)"
        redirect_back fallback_location: profile_path
      end
    else
      render file: "/public/404", status: 404
    end
  end

  private

  def address_params
    params[:address][:user_id] = current_user.id
    params.require(:address).permit(:nickname, :street, :city, :state, :zip, :user_id)
  end
end
