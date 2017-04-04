class RenameNonProfitDomainNameToHomepage < ActiveRecord::Migration
  def change
  	rename_column :non_profits, :domain_name, :homepage
  	add_column :non_profits, :domain_name, :string
  end
end
