class AddImageToProcessor < ActiveRecord::Migration
  def change
  	add_column :processors, :image, :string
  end
end
