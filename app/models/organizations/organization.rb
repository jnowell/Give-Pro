class Organization < ActiveRecord::Base
	has_many :amount_regexes
	has_many :org_regexes
	mount_uploader :image, ImageUploader

	accepts_nested_attributes_for :amount_regexes
	accepts_nested_attributes_for :org_regexes
end