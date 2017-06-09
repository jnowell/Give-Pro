class RenameNonProfitToOrganization < ActiveRecord::Migration
  def change
  	rename_table :non_profits, :organizations
  	add_column :organizations, :type, :string
  	add_column :organizations, :check_donation_string, :string
  	add_column :organizations, :org_regex, :string
  end
end
