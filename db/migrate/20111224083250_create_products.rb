class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :item_code
      t.string :item_grp_code
      t.string :code_bars
      t.integer :num_in_buy
      t.integer :per_pack_un
      t.integer :diameter
      t.string :omlabel
      t.integer :max_pallet
      t.string :fetim_code

      t.timestamps
    end
  end
end
