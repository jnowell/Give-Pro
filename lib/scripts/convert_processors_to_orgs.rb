require 'fileutils'

processors = ::Processor.all
count = 0

for processor in processors
	org = NonProfit.new
	org.name = processor.name
	org.alias = processor.name
	org.domain_name = processor.domain
	org.org_regex = processor.org_regex
	org.amount_regex = processor.amount_regex
	org.check_donation_string = processor.check_donation_string
	org.image = processor.image
	if processor.image.present?
		file1 = Rails.root.join('app', 'assets', 'images', 'processors', processor.image)
		file2 = Rails.root.join('app', 'assets', 'images', 'org_logos')
		
		#FileUtils.move file1.to_s, file2.to_s
	end
	count += 1
	if org.save
		puts "Org saved with ID #{org.id}"
	else
		puts "Error saving org"
	end
end

puts "Added #{count} processor"