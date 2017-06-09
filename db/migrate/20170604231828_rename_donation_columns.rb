class RenameDonationColumns < ActiveRecord::Migration
  def change
  	rename_column :donations, :non_profit_string, :organization_string
  	rename_column :donations, :NonProfit_id, :Organization_id
  end
end
