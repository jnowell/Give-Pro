class AddOrgRegex < ActiveRecord::Migration
  def change
  	create_table :org_regexes do |t|
      t.belongs_to :organization, index: true
      t.string :regex
    end
  end
end
