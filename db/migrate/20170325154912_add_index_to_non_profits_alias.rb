class AddIndexToNonProfitsAlias < ActiveRecord::Migration
  def change
  	add_index :non_profits, :alias
  end
end
