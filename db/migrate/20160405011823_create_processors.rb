class CreateProcessors < ActiveRecord::Migration
  def change
    create_table :processors do |t|
      t.string :name
      t.string :domain
      t.string :regex

      t.timestamps null: false
    end
  end
end
