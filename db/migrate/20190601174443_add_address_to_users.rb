class AddAddressToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :primary_address_id, :bigint, index: true
    add_foreign_key :users, :addresses, column: :primary_address_id
  end
end
