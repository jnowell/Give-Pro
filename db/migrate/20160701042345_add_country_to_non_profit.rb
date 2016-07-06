class AddCountryToNonProfit < ActiveRecord::Migration
  def change
    add_column :non_profits, :country, :string
  end
end
