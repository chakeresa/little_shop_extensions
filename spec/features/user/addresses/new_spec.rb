require 'rails_helper'

RSpec.describe "Adding a new address" do
  context "as a logged in regular user" do
    it "I can add an address from the cart show page with addresses already" do
      merchant_1 = create(:merchant)
      item_1 = create(:item, user: merchant_1, name: "Sofa")

      user_1 = create(:user)
      addr_1 = create(:address, user: user_1)
      addr_2 = create(:address, user: user_1)
      user_1.update!(primary_address_id: addr_2.id)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_1)

      visit item_path(item_1)
      click_button "Add to Cart"

      visit cart_path

      click_link "Add a New Address"

      expect(current_path).to eq(new_user_address_path)
    end

    it "I can add an address from the cart show page with no addresses yet" do
      merchant_1 = create(:merchant)
      item_1 = create(:item, user: merchant_1, name: "Sofa")

      user_1 = create(:user)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_1)

      visit item_path(item_1)
      click_button "Add to Cart"

      visit cart_path

      click_link "Add a New Address"

      expect(current_path).to eq(new_user_address_path)
    end

    it "I can add an address from the profile page" do
      user_1 = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_1)

      visit profile_path

      click_link "Add a New Address"

      expect(current_path).to eq(new_user_address_path)
    end

    it "has a form to add a new address" do
      user_1 = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_1)

      nickname = "my work"
      street = "123 go to santa lane"
      city = "aurora"
      state = "colorado"
      zip = "123311"

      visit new_user_address_path

      fill_in "address[nickname]", with: nickname
      fill_in "address[street]", with: street
      fill_in "address[city]", with: city
      fill_in "address[state]", with: state
      fill_in "address[zip]", with: zip

      click_on "Add Address"

      expect(current_path).to eq(profile_path)

      new_address = Address.last

      expect(page).to have_content("Added \"#{nickname}\" address")
      expect(user_1.reload.addresses[-1]).to eq(new_address)
      expect(new_address.nickname).to eq(nickname)
      expect(new_address.street).to eq(street)
      expect(new_address.city).to eq(city)
      expect(new_address.state).to eq(state)
      expect(new_address.zip).to eq(zip)
    end

    it "if nickname field is left blank, it defaults to home" do
      user_1 = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_1)

      street = "123 go to santa lane"
      city = "aurora"
      state = "colorado"
      zip = "123311"

      visit new_user_address_path

      # DON'T fill_in "address[nickname]"
      fill_in "address[street]", with: street
      fill_in "address[city]", with: city
      fill_in "address[state]", with: state
      fill_in "address[zip]", with: zip

      click_on "Add Address"

      new_address = Address.last

      expect(page).to have_content("Added \"home\" address")
      expect(user_1.reload.addresses[-1]).to eq(new_address)
      expect(new_address.nickname).to eq("home")
      expect(new_address.street).to eq(street)
      expect(new_address.city).to eq(city)
      expect(new_address.state).to eq(state)
      expect(new_address.zip).to eq(zip)
    end

    it "street input is required" do
      user_1 = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_1)

      nickname = "my work"
      # street = "123 go to santa lane"
      city = "aurora"
      state = "colorado"
      zip = "123311"

      visit new_user_address_path

      fill_in "address[nickname]", with: nickname
      # DON'T fill_in "address[street]", with: street
      fill_in "address[city]", with: city
      fill_in "address[state]", with: state
      fill_in "address[zip]", with: zip

      click_on "Add Address"

      expect(page).to have_field("address[nickname]")
      expect(page).to have_content("Street can't be blank")
    end

    it "city input is required" do
      user_1 = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_1)

      nickname = "my work"
      street = "123 go to santa lane"
      # city = "aurora"
      state = "colorado"
      zip = "123311"

      visit new_user_address_path

      fill_in "address[nickname]", with: nickname
      fill_in "address[street]", with: street
      # DON'T fill_in "address[city]", with: city
      fill_in "address[state]", with: state
      fill_in "address[zip]", with: zip

      click_on "Add Address"

      expect(page).to have_field("address[nickname]")
      expect(page).to have_content("City can't be blank")
    end

    it "state input is required" do
      user_1 = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_1)

      nickname = "my work"
      street = "123 go to santa lane"
      city = "aurora"
      # state = "colorado"
      zip = "123311"

      visit new_user_address_path

      fill_in "address[nickname]", with: nickname
      fill_in "address[street]", with: street
      fill_in "address[city]", with: city
      # DON'T fill_in "address[state]", with: state
      fill_in "address[zip]", with: zip

      click_on "Add Address"

      expect(page).to have_field("address[nickname]")
      expect(page).to have_content("State can't be blank")
    end

    it "zip input is required" do
      user_1 = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user_1)

      nickname = "my work"
      street = "123 go to santa lane"
      city = "aurora"
      state = "colorado"
      # zip = "123311"

      visit new_user_address_path

      fill_in "address[nickname]", with: nickname
      fill_in "address[street]", with: street
      fill_in "address[city]", with: city
      fill_in "address[state]", with: state
      # DON'T fill_in "address[zip]", with: zip

      click_on "Add Address"

      expect(page).to have_field("address[nickname]")
      expect(page).to have_content("Zip can't be blank")
    end
  end
end
