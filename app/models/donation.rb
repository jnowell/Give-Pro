class Donation < ActiveRecord::Base
  belongs_to :User
  belongs_to :NonProfit
  belongs_to :Processor
  validates :amount, presence: true
  validates :donation_date, presence: true
  validates :non_profit_string, presence: true

  def has_image
	return ((!(self.NonProfit.nil?) and (self.NonProfit.image.present?)) or (!(self.Processor.nil?) and (self.Processor.image.present?)))
  end
end
