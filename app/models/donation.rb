class Donation < ActiveRecord::Base
  belongs_to :User
  belongs_to :Organization
  validates :amount, presence: true
  validates :donation_date, presence: true
  validates :organization_string, presence: true

  def has_image
	return (!(self.Organization.nil?) and (self.Organization.image.present?))
  end
end
