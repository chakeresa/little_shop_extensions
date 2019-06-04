require 'rails_helper'

RSpec.describe "Editing an existing address" do
  context "as a logged in regular user" do
    before(:each) do
      @user_1 = create(:user)
      @addr_1 = create(:address, user: @user_1)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user_1)

      @nickname = "my work"
      @street = "123 go to santa lane"
      @city = "aurora"
      @state = "colorado"
      @zip = "123311"
    end

    it "I can edit an address from the profile page" do
      visit profile_path

      within("#address-#{@addr_1.id}") do
        click_link "Edit Address"
      end

      expect(current_path).to eq(edit_user_address_path(@addr_1))
    end

    it "has a form to edit an address" do
      visit edit_user_address_path(@addr_1)

      fill_in "address[nickname]", with: @nickname
      fill_in "address[street]", with: @street
      fill_in "address[city]", with: @city
      fill_in "address[state]", with: @state
      fill_in "address[zip]", with: @zip

      click_on "Update Address"

      expect(current_path).to eq(profile_path)

      expect(page).to have_content("Updated \"#{@nickname}\" address")
      expect(@addr_1.reload.nickname).to eq(@nickname)
      expect(@addr_1.reload.street).to eq(@street)
      expect(@addr_1.reload.city).to eq(@city)
      expect(@addr_1.reload.state).to eq(@state)
      expect(@addr_1.reload.zip).to eq(@zip)
    end

    it "nickname input is required" do
      visit edit_user_address_path(@addr_1)

      fill_in "address[nickname]", with: ""
      fill_in "address[street]", with: @street
      fill_in "address[city]", with: @city
      fill_in "address[state]", with: @state
      fill_in "address[zip]", with: @zip

      click_on "Update Address"

      expect(page).to have_field("address[nickname]")
      expect(page).to have_content("Nickname can't be blank")
    end

    it "street input is required" do
      visit edit_user_address_path(@addr_1)

      fill_in "address[nickname]", with: @nickname
      fill_in "address[street]", with: ""
      fill_in "address[city]", with: @city
      fill_in "address[state]", with: @state
      fill_in "address[zip]", with: @zip

      click_on "Update Address"

      expect(page).to have_field("address[nickname]")
      expect(page).to have_content("Street can't be blank")
    end

    it "city input is required" do
      visit edit_user_address_path(@addr_1)

      fill_in "address[nickname]", with: @nickname
      fill_in "address[street]", with: @street
      fill_in "address[city]", with: ""
      fill_in "address[state]", with: @state
      fill_in "address[zip]", with: @zip

      click_on "Update Address"

      expect(page).to have_field("address[nickname]")
      expect(page).to have_content("City can't be blank")
    end

    it "state input is required" do
      visit edit_user_address_path(@addr_1)

      fill_in "address[nickname]", with: @nickname
      fill_in "address[street]", with: @street
      fill_in "address[city]", with: @city
      fill_in "address[state]", with: ""
      fill_in "address[zip]", with: @zip

      click_on "Update Address"

      expect(page).to have_field("address[nickname]")
      expect(page).to have_content("State can't be blank")
    end

    it "zip input is required" do
      visit edit_user_address_path(@addr_1)

      fill_in "address[nickname]", with: @nickname
      fill_in "address[street]", with: @street
      fill_in "address[city]", with: @city
      fill_in "address[state]", with: @state
      fill_in "address[zip]", with: ""

      click_on "Update Address"

      expect(page).to have_field("address[nickname]")
      expect(page).to have_content("Zip can't be blank")
    end

    it "I cannot see the form to update another user's address" do
      @addr_1.update(user: create(:user))

      visit edit_user_address_path(@addr_1)

      expect(status_code).to eq(404)
    end

    it "I cannot update another user's address" do
      visit edit_user_address_path(@addr_1)

      @addr_1.update(user: create(:user))

      fill_in "address[nickname]", with: @nickname
      click_on "Update Address"

      expect(status_code).to eq(404)
      expect(@addr_1.reload.nickname).to_not eq(@nickname)
    end

    it "there is no button on my profile page to edit addresses associated with completed orders" do
      addr_2 = create(:address, user: @user_1)
      pending_order = create(:order, address: addr_2, user: @user_1)

      addr_3 = create(:address, user: @user_1)
      packaged_order = create(:packaged_order, address: addr_3, user: @user_1)

      addr_4 = create(:address, user: @user_1)
      shipped_order = create(:shipped_order, address: addr_4, user: @user_1)

      addr_5 = create(:address, user: @user_1)
      cancelled_order = create(:cancelled_order, address: addr_5, user: @user_1)

      visit profile_path

      within("#address-#{addr_2.id}") do
        expect(page).to have_link("Edit Address")
      end

      within("#address-#{addr_3.id}") do
        expect(page).to_not have_link("Edit Address")
      end

      within("#address-#{addr_4.id}") do
        expect(page).to_not have_link("Edit Address")
      end

      within("#address-#{addr_5.id}") do
        expect(page).to have_link("Edit Address")
      end
    end

    it "I cannot edit an address associated with a completed (shipped or packaged) order" do
      addr_3 = create(:address, user: @user_1)
      packaged_order = create(:packaged_order, address: addr_3, user: @user_1)

      addr_4 = create(:address, user: @user_1)
      shipped_order = create(:shipped_order, address: addr_4, user: @user_1)

      visit edit_user_address_path(addr_3)

      fill_in "address[nickname]", with: @nickname
      click_on "Update Address"

      expect(page).to have_content("Cannot change an address that was used for packaged/shipped order(s)")
      expect(@addr_1.reload.nickname).to_not eq(@nickname)

      visit edit_user_address_path(addr_4)

      fill_in "address[nickname]", with: @nickname
      click_on "Update Address"

      expect(page).to have_content("Cannot change an address that was used for packaged/shipped order(s)")
      expect(@addr_1.reload.nickname).to_not eq(@nickname)
    end

    it "I can edit an address associated with a pending or cancelled order" do
      addr_2 = create(:address, user: @user_1)
      pending_order = create(:order, address: addr_2, user: @user_1)

      addr_5 = create(:address, user: @user_1)
      cancelled_order = create(:cancelled_order, address: addr_5, user: @user_1)

      visit edit_user_address_path(addr_2)

      fill_in "address[zip]", with: @zip
      click_on "Update Address"

      expect(current_path).to eq(profile_path)

      expect(page).to have_content("Updated \"#{addr_2.nickname}\" address")
      expect(addr_2.reload.zip).to eq(@zip)

      visit edit_user_address_path(addr_5)

      fill_in "address[street]", with: @street
      click_on "Update Address"

      expect(current_path).to eq(profile_path)

      expect(page).to have_content("Updated \"#{addr_5.nickname}\" address")
      expect(addr_5.reload.street).to eq(@street)
    end
  end
end
