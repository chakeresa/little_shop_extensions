class CreateBulkDiscounts < ActiveRecord::Migration[5.1]
  def change
    create_table :bulk_discounts do |t|
      t.references :user, foreign_key: true
      t.integer :bulk_quantity
      t.decimal :pc_off

      t.timestamps
    end
  end
end
