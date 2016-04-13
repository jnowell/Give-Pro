class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.float :amount
      t.date :donation_date
      t.boolean :recurring
      t.boolean :matching
      t.references :User, index: true, foreign_key: true
      t.references :NonProfit, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
