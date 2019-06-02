class User::AddressesController < User::BaseController
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
end
