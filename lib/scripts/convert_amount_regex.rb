count = 0

orgs = ::Organization.where("amount_regex is not null")

count = 0

for org in orgs
	amount_regex = AmountRegex.new(:regex => org.amount_regex, :organization_id => org.id)
	puts "Amount regex of #{amount_regex.id}"
	if amount_regex.save
		puts "amount_regex saved with ID #{amount_regex.id}"
	else
		puts "Error saving amount_regex"
	end
end