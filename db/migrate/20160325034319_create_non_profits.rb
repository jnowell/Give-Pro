class CreateNonProfits < ActiveRecord::Migration
  def change
    create_table :non_profits do |t|
      t.integer :ein
      t.string :name
      t.string :alias
      t.boolean :tax_exempt
      t.string :domain_name
      t.string :status_code
      t.string :donation_page_url
      t.string :image_url

      t.timestamps null: false
    end
  end
end
