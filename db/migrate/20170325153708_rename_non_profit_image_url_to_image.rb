class RenameNonProfitImageUrlToImage < ActiveRecord::Migration
  def change
  	rename_column :non_profits, :image_url, :image
  end
end
