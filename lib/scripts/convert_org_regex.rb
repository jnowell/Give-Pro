count = 0

orgs = ::Organization.where("org_regex is not null")

count = 0

for org in orgs
	org_regex = OrgRegex.new(:regex => org.org_regex, :organization_id => org.id)
	puts "Org regex of #{org_regex.id}"
	if org_regex.save
		puts "org_regex saved with ID #{org_regex.id}"
	else
		puts "Error saving org_regex"
	end
end