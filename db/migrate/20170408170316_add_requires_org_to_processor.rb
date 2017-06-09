class AddRequiresOrgToProcessor < ActiveRecord::Migration
  def change
  	add_column :processors, :requires_org, :boolean
  	rename_column :processors, :regex, :org_regex
  	add_column :processors, :amount_regex, :string
  end
end
