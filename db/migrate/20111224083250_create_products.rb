class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :item_code, :null => false
      t.string :item_grp_code
      t.string :code_bars
      t.integer :num_in_buy
      t.integer :per_pack_un
      t.string :size
      t.string :omlabel
      t.integer :max_pallet
      t.string :fetim_code
      t.string :status, :default => 'active', :null => false

      t.timestamps
    end

    add_index :products, :item_code, :unique => true
  end
end
