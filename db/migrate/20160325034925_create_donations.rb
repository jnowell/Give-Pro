class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.float :amount
      t.date :donation_date
      t.boolean :recurring
      t.boolean :matching
      t.references :User
      t.references :Organization
      t.timestamps null: false
    end
    add_foreign_key :donations, :users
  end
end
