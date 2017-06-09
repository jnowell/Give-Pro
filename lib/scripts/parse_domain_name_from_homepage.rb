orgs = NonProfit.where.not('domain_name' => nil)
count = 0

for org in orgs
	if org.homepage.exists?
		next
	end
	puts "Org ID of #{org.id}"
	puts "Org domain name of #{org.domain_name}"
	if org.domain_name.present?
                org.homepage = org.domain_name
		puts "ORG HOMEPAGE OF #{org.homepage}"
		begin
			org.domain_name = Addressable::URI.parse(org.homepage).host.split('.').last(2).join('.')
			puts "Org domain name of #{org.domain_name}"
			if org.save
				count += 1
			else
				puts "Error saving"
			end
		rescue
			puts "Error for org ID #{org.id} and homepage #{org.homepage}"
		end 
	end
end

puts "Added domain name for #{count} non-profit records"
