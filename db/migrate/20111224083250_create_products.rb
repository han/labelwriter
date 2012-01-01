class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :item_code
      t.string :fetim_code
      t.string :fetim_name
      t.string :size
      t.integer :per_vpe
      t.integer :per_box
      t.string :barcode

      t.timestamps
    end
  end
end
