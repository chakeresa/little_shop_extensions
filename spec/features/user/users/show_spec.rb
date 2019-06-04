require 'rails_helper'

RSpec.describe "profile page" do
  context "as a user" do
    before(:each) do
      @user = User.create!(email: "abc@def.com", password: "pw123", name: "Abc Def")
      @address = Address.create!(nickname: "work", street: "123 Abc St", city: "NYC", state: "NY", zip: "12345", user: @user)
      @another_address = Address.create!(nickname: "home", street: "Blah Ln", city: "Denver", state: "CO", zip: "80221", user: @user)
      @user.update(primary_address_id: @address.id)

      allow_any_instance_of(ApplicationController).to receive(:current_user)
        .and_return(@user)
    end

    it "shows my profile data including all addresses" do
      visit profile_path

      expect(page).to have_content(@user.name)
      expect(page).to have_content(@user.email)

      within("#address-#{@address.id}") do
        expect(page).to have_content("#{@address.nickname} (primary address)")
        expect(page).to have_content(@address.street)
        expect(page).to have_content("#{@address.city}, #{@address.state}")
        expect(page).to have_content(@address.zip)
      end

      within("#address-#{@another_address.id}") do
        expect(page).to_not have_content("(primary address)")
        expect(page).to have_content(@another_address.nickname)
        expect(page).to have_content(@another_address.street)
        expect(page).to have_content("#{@another_address.city}, #{@another_address.state}")
        expect(page).to have_content(@another_address.zip)
      end
    end

    it "has buttons to delete my addresses" do
      visit profile_path

      original_street = @another_address.street
      original_nickname = @another_address.nickname

      within("#address-#{@address.id}") do
        expect(page).to have_button("Delete Address")
      end

      within("#address-#{@another_address.id}") do
        click_button "Delete Address"
      end

      expect(current_path).to eq(profile_path)
      expect(page).to_not have_content(original_street)
      expect(page).to have_content("#{original_nickname.titlecase} address has been deleted")
    end

    it "I can't delete someone else's address" do
      visit profile_path

      original_addr_id = @address.id
      another_user = create(:user)
      @address.update!(user: another_user)

      within("#address-#{@address.id}") do
        click_button "Delete Address"
      end

      expect(status_code).to eq(404)
      expect(@address.reload.id).to eq(original_addr_id)
    end

    it "I can delete an address with associated pending orders" do
      order = create(:order, address: @address) # pending order
      original_addr_id = @address.id
      original_addr_nickname = @address.nickname
      original_addr_street = @address.street

      visit profile_path

      within("#address-#{@address.id}") do
        click_button "Delete Address"
      end

      expect(current_path).to eq(profile_path)
      expect(page).to have_content("#{original_addr_nickname.titlecase} address has been deleted")
      expect(page).to_not have_content(original_addr_street)
    end

    it "I can delete an address with associated cancelled orders" do
      order = create(:cancelled_order, address: @address)
      original_addr_id = @address.id
      original_addr_nickname = @address.nickname
      original_addr_street = @address.street

      visit profile_path

      within("#address-#{@address.id}") do
        click_button "Delete Address"
      end

      expect(current_path).to eq(profile_path)
      expect(page).to have_content("#{original_addr_nickname.titlecase} address has been deleted")
      expect(page).to_not have_content(original_addr_street)
    end

    it "I can't delete an address with associated packaged orders" do
      original_addr_id = @address.id

      visit profile_path

      order = create(:packaged_order, address: @address)

      within("#address-#{@address.id}") do
        click_button "Delete Address"
      end

      expect(current_path).to eq(profile_path)
      expect(page).to have_content("Cannot delete an address that was used for packaged/shipped order(s)")
      expect(@address.reload.id).to eq(original_addr_id)
    end

    it "I can't delete an address with associated shipped orders" do
      original_addr_id = @address.id

      visit profile_path
      
      order = create(:shipped_order, address: @address)

      within("#address-#{@address.id}") do
        click_button "Delete Address"
      end

      expect(current_path).to eq(profile_path)
      expect(page).to have_content("Cannot delete an address that was used for packaged/shipped order(s)")
      expect(@address.reload.id).to eq(original_addr_id)
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
