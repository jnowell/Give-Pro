require 'aws-sdk'
require 'nokogiri'


Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new(ENV["AWS_ACCESS_KEY_ID"], ENV["AWS_SECRET_ACCESS_KEY"])
})

s3 = Aws::S3::Client.new(region: 'us-east-1')
websites_added = 0
new_orgs_added = 0
orgs_looked_at = 0

key_count = 1000
key = nil
doc = nil
bucket = s3.list_objects_v2({bucket: "irs-form-990"})
while (key_count == 1000)
	key_count = bucket.key_count
	for content in bucket.contents
		key = content.key
		if key != "AMAZON_SES_SETUP_NOTIFICATION"
			orgs_looked_at += 1
			begin
				resp = s3.get_object({bucket: 'irs-form-990', key: content.key})
				doc = Nokogiri::XML(resp.body.read)
				
				block = doc.css("Filer EIN")
				ein = block.children.first.content
				non_profit = NonProfit.find_by(ein: ein)
				save = false
				if non_profit.nil?
					non_profit = NonProfit.new(:ein => ein)
					non_profit.ein = ein
					non_profit.name = doc.css("Filer Name BusinessNameLine1").children.first.content
		    		non_profit.alias = non_profit.name  
		    		address = doc.css("Filer USAddress AddressLine1")  
		    		if address.children.first    
		    			non_profit.address = address.children.first.content
		    			non_profit.city = doc.css("Filer USAddress City").children.first.content
			   			non_profit.state = doc.css("Filer USAddress State").children.first.content
		    			non_profit.zip = doc.css("Filer USAddress ZIPCode").children.first.content
		    		else
		    			non_profit.address = doc.css("Filer ForeignAddress AddressLine1").children.first.content
		    			non_profit.city = doc.css("Filer ForeignAddress City").children.first.content
			   			non_profit.country = doc.css("Filer ForeignAddress Country").children.first.content
		    			non_profit.zip = doc.css("Filer ForeignAddress PostalCode").children.first.content
		    		end
		    		new_orgs_added += 1
		    		save = true
				end
				website = doc.css("WebSite")
				if website.children.first
					url = website.children.first.content.downcase
					#length check to account for some 'N/A' and 'None' in data
					if url.length > 5 and non_profit.domain_name.nil?
						unless url.start_with? "http"
							url.prepend("http://")
						end
						non_profit.domain_name = url
						websites_added += 1
						save = true
						non_profit.domain_name = url
					end
				end
				if save 
					unless non_profit.save
						puts "Error saving non profit with EIN #{ein}"
					end
				end
			rescue
				puts "ERROR: Error saving document with EIN #{ein}"
				puts doc
			end
		end
	end
	puts "Key value of #{key}"
	bucket = s3.list_objects_v2({bucket: "irs-form-990", start_after: key})
	puts "Continuing with #{orgs_looked_at}"
	puts "Continuing with #{websites_added} websites added"
	puts "Continuing with #{new_orgs_added} new orgs added"
end

puts "#{websites_added} Total Websites Added"
puts "#{new_orgs_added} New Organizations Added"
puts "#{orgs_looked_at} Total Organizations Looked At"