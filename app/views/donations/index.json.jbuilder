json.array!(@donations) do |donation|
  json.extract! donation, :id, :amount, :donation_date, :recurring, :matching, :User_id, :NonProfit_id
  json.url donation_url(donation, format: :json)
end
