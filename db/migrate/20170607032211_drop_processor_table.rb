class DropProcessorTable < ActiveRecord::Migration
  def change
  	drop_table :processors
  end
end
