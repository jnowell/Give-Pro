class AddDetailsToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :non_profit_string, :string
    add_column :donations, :deductible, :boolean
  end
end
