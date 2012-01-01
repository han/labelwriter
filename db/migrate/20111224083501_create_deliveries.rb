class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.integer :product_id
      t.string :purchase_order
      t.integer :order_quantity
      t.integer :actual_quantity
      t.date :shipped_at
      t.date :delivered_at
      t.string :tour_number

      t.timestamps
    end
  end
end
