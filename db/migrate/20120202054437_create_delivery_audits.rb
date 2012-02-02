class CreateDeliveryAudits < ActiveRecord::Migration
  def change
    create_table :delivery_audits do |t|
      t.text :info
      t.string :type
      t.integer :user

      t.timestamps
    end
  end
end
