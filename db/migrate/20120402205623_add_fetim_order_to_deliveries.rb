class AddFetimOrderToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :fetim_order, :string

  end
end
