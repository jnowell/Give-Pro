class CreateNonProfits < ActiveRecord::Migration
  def change
    create_table :non_profits do |t|
      t.integer :ein
      t.string :name
      t.string :alias
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.integer :subscection
      t.integer :classification
      t.datetime :ruling_date
      t.integer :exemption_code
      t.integer :foundation_code
      t.string :domain_name
      t.string :status_code
      t.string :donation_page_url
      t.string :image_url

      t.timestamps null: false
    end
  end
end
