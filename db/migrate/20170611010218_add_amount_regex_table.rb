class AddAmountRegexTable < ActiveRecord::Migration
  def change
  	create_table :amount_regexes do |t|
      t.belongs_to :organization, index: true
      t.string :regex
    end
  end
end
