count = 0

donations = ::Donation.where("Processor_id is not null")

first_count = 1
last_count = 1806724
total_count = 5

id_map = Hash.new
while first_count <= total_count 
	id_map[first_count] = last_count
	first_count += 1
	last_count += 1
end 

for donation in donations
	puts "Donation of #{donation.id}"
	processor_id = donation.Processor_id
	donation.Organization_id = id_map[processor_id]
	if donation.save
		puts "Donation saved with ID #{donation.id}"
	else
		puts "Error saving donation with ID #{donation.id}"
	end
end