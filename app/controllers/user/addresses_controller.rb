class User::AddressesController < User::BaseController
  def new
    @user = current_user
    @address = Address.new
  end

  def create
    require "pry"; binding.pry
    @address = Address.new(address_params)
    if @address.save
      flash[:success] = "Added #{@address.nickname} address"
      redirect_to profile_path
    else
      flash[:danger] = @address.errors.full_messages.join(". ")
      @user = current_user
      render :new
    end
  end

  def destroy
    address = Address.find(params[:id])
    if address.user_id == current_user.id
      if address.no_orders?
        Address.destroy(address.id)
        redirect_to profile_path
        return
      else
        flash[:danger] = "Cannot delete an address that was used for an order"
        redirect_back fallback_location: profile_path
      end
    else
      render file: "/public/404", status: 404
    end
  end

  private

  def address_params
    params.require(:address).permit(:nickname, :street, :city, :state, :zip, :user_id)
  end
end
