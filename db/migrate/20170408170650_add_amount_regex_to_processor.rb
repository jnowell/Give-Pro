class AddAmountRegexToProcessor < ActiveRecord::Migration
  def change
  	rename_column :processors, :regex, :org_regex
  	add_column :processors, :amount_regex, :string
  end
end
