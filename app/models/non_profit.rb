class NonProfit < ActiveRecord::Base
  mount_uploader :image, ImageUploader
	
end
