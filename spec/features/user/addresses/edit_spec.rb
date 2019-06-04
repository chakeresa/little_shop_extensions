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

    xit "there is no button on my profile page to edit addresses associated with completed orders" do

    end

    xit "I cannot edit an address associated with a completed order" do

    end
  end
end
