require 'rails_helper'

RSpec.describe "profile edit page" do
  context "as a user" do
    before(:each) do
      @email = "abc@def.com"
      @password = "pw123"
      @name = "Abc Def"
      @user = User.create!(email: @email, password: @password, name: @name)

      visit login_path

      within('.login-form') do
        fill_in "Email", with: @email
        fill_in "Password", with: @password
        click_on "Login"
      end
    end

    it "shows a form to edit my profile data" do
      visit profile_edit_path

      expect(page).to have_field("user[name]")
      expect(page).to have_field("user[email]")
      expect(page).to have_field("user[password]")
      expect(page).to have_field("user[password_confirmation]")

      click_button "Submit Changes"

      expect(current_path).to eq(profile_path)

      expect(page).to have_content(@user.name)
      expect(page).to have_content(@user.email)
    end

    it "I can edit my name" do
      visit profile_edit_path

      new_name = "Bob"

      fill_in "user[name]", with: new_name
      click_button "Submit Changes"

      expect(page).to have_content("Your profile has been updated")
      expect(page).to have_content(new_name)
      expect(page).to_not have_content(@name)
    end

    it "I can change my email to an unused email address" do
      visit profile_edit_path

      new_email = "Bob@Bobbin.com"

      fill_in "user[email]", with: new_email
      click_button "Submit Changes"

      expect(page).to have_content("Your profile has been updated")
      expect(page).to have_content(new_email.downcase)
      expect(page).to_not have_content(@email)
    end

    it "I cannot change my email to an already used email address" do
      new_email = "Bob@Bobbin.com"
      create(:user, email: new_email)

      visit profile_edit_path

      fill_in "user[email]", with: new_email
      click_button "Submit Changes"

      expect(current_path).to eq(profile_edit_path)

      expect(page).to_not have_content("Your profile has been updated")
      expect(page).to_not have_content(new_email)
      expect(page).to have_content("That email address is already in use")
    end

    it "I can edit my password (when confirmation matches)" do
      visit profile_edit_path

      new_password = "newPassword"
      original_pw_digest = @user.password_digest

      fill_in "user[password]", with: new_password
      fill_in "user[password_confirmation]", with: new_password
      click_button "Submit Changes"

      expect(page).to have_content("Your profile has been updated")
      @user.reload
      expect(@user.password_digest).to_not eq(original_pw_digest)
    end

    it "my password doesn't change when confirmation doesn't match" do
      visit profile_edit_path

      new_password = "newPassword"
      original_pw_digest = @user.password_digest

      fill_in "user[password]", with: new_password.downcase
      fill_in "user[password_confirmation]", with: new_password.upcase
      click_button "Submit Changes"

      expect(page).to_not have_content("Your profile has been updated")
      expect(page).to have_content("Password confirmation doesn't match Password")
      expect(current_path).to eq(profile_edit_path)

      @user.reload
      expect(@user.password_digest).to eq(original_pw_digest)
    end

    it "leaving password blank doesn't change my password" do
      visit profile_edit_path

      new_password = ""
      original_pw_digest = @user.password_digest

      fill_in "user[password]", with: new_password
      fill_in "user[password_confirmation]", with: new_password
      click_button "Submit Changes"

      @user.reload
      expect(@user.password_digest).to eq(original_pw_digest)
    end
  end
end
