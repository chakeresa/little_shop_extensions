class User::AddressesController < User::BaseController
  def destroy
    address = Address.find(params[:id])
    if address.user_id == current_user.id
      # to-do: make sure there are no orders with this ID
      Address.destroy(address.id)
      redirect_to profile_path
    else
      render file: "/public/404", status: 404
    end
  end
end
