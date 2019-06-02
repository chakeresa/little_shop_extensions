require 'rails_helper'

RSpec.describe "Cancelling an order", type: :feature do
  context "as a user" do
    before(:each) do
      @user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user)
                                                  .and_return(@user)

      @pending_order = create(:order, user: @user) # pending by default
      @packaged_order = create(:packaged_order, user: @user)
      @shipped_order = create(:shipped_order, user: @user)
      @cancelled_order = create(:cancelled_order, user: @user)

      @item_1_initial_inventory = 30
      @item_2_initial_inventory = 40
      @item_1 = create(:item, inventory: @item_1_initial_inventory)
      @item_2 = create(:item, inventory: @item_2_initial_inventory)

      @oi_1 = create(:order_item, order: @pending_order, item: @item_1, quantity: 10)
      @oi_2 = create(:fulfilled_order_item, order: @pending_order, item: @item_2, quantity: 5)
    end

    it "if order is pending there is a button to cancel" do
      visit user_order_path(@pending_order)

      click_button "Cancel Order"

      expect(current_path).to eq(profile_path)
      expect(page).to have_content("Order #{@pending_order.id} has been cancelled")

      expect(@oi_1.reload.fulfilled).to eq(false)
      expect(@oi_2.reload.fulfilled).to eq(false)
      expect(@pending_order.reload.status).to eq("cancelled")

      visit user_orders_path

      within("#order-#{@pending_order.id}") do
        expect(page).to have_content("cancelled")
      end

      expect(@item_1.reload.inventory).to eq(@item_1_initial_inventory)
      expect(@item_2.reload.inventory).to eq(@item_2_initial_inventory + @oi_2.quantity)
    end

    it "if order is not pending there is no button to cancel" do
      visit user_order_path(@packaged_order)
      expect(page).to_not have_button("Cancel Order")

      visit user_order_path(@shipped_order)
      expect(page).to_not have_button("Cancel Order")

      visit user_order_path(@cancelled_order)
      expect(page).to_not have_button("Cancel Order")
    end
  end
end