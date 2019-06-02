require 'rails_helper'

RSpec.describe "profile page" do
  context "as a user" do
    before(:each) do
      @user = User.create!(email: "abc@def.com", password: "pw123", name: "Abc Def")
      @address = Address.create!(street: "123 Abc St", city: "NYC", state: "NY", zip: "12345", user: @user)
      @another_address = Address.create!(street: "Blah Ln", city: "Denver", state: "CO", zip: "80221", user: @user)

      allow_any_instance_of(ApplicationController).to receive(:current_user)
        .and_return(@user)
    end

    it "shows my profile data including all addresses" do
      visit profile_path

      expect(page).to have_content(@user.name)
      expect(page).to have_content(@user.email)
      expect(page).to have_content(@address.street)
      expect(page).to have_content("#{@address.city}, #{@address.state}")
      expect(page).to have_content(@address.zip)
      expect(page).to have_content(@another_address.street)
      expect(page).to have_content("#{@another_address.city}, #{@another_address.state}")
      expect(page).to have_content(@another_address.zip)
    end

    it "has a link to edit my profile data" do
      visit profile_path

      click_link "Edit My Profile or Password"

      expect(current_path).to eq(profile_edit_path)
    end
  end

  context "as a registered user" do
    it "displays a link to my orders, if I have orders placed in the system" do
      user = create(:user)
      merchant = create(:merchant)

      order = create(:order, user: user)

      item_1 = create(:item, user: merchant)
      item_2 = create(:item, user: merchant)

      oi_1 = create(:order_item, item: item_1, order: order, quantity: 3, price_per_item: item_1.price)
      oi_2 = create(:order_item, item: item_2, order: order, quantity: 1, price_per_item: item_2.price)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit profile_path

      click_link "My Orders"

      expect(current_path).to eq(user_orders_path)
    end

    it "does NOT display a link to my orders, if no orders are placed in the system" do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

      visit profile_path

      expect(page).to_not have_link("My Orders")
    end
  end
end
