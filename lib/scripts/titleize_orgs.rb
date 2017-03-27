
non_profits = NonProfit.all

orgs_saved = 0

for non_profit in non_profits
	non_profit.name = non_profit.name.titleize
	non_profit.alias = non_profit.alias.titleize
	non_profit.city = non_profit.city.titleize
	non_profit.address = non_profit.address.titleize
	if non_profit.save
		orgs_saved += 1
	else
		puts "Error saving non profit with EIN #{non_profit.ein}"
	end
end

puts "Total orgs saved: #{orgs_saved}"