class AddCheckDonationStringToProcessor < ActiveRecord::Migration
  def change
  	add_column :processors, :check_donation_string, :string
  end
end
