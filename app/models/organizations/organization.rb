class Organization < ActiveRecord::Base
	has_many :amount_regexes
	mount_uploader :image, ImageUploader

end