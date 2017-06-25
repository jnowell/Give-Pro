
eins = NonProfit.select(:ein).group(:ein).having("count(*) > 1")
count = 0

for ein in eins
	non_profits = NonProfit.where("ein = ?", ein.ein).order(id: :desc).limit(1)
	for non_profit in non_profits
		#puts "Deleting non-profit with ID #{non_profit.id}"
		non_profit.destroy
		count += 1
		if ((count % 1000) == 0)
			puts "Count of #{count}"
		end
	end
end

puts "Deleted #{count} non-profit records"