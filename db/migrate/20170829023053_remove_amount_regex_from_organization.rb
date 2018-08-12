class RemoveAmountRegexFromOrganization < ActiveRecord::Migration
  def change
  	remove_column :organizations, :amount_regex
  end
end
