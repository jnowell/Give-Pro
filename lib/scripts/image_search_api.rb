require 'net/http'
require 'json'
require 'open-uri'
require 'rest-client'

#donations = Donation.joins(:NonProfit).where(non_profits: {image_url: nil})

donations = Donation.where("id >= 21")

for donation in donations
	if ((donation.id == 1) or (donation.NonProfit.image_url.present?))
		next
	end
	puts "Donation of ID #{donation.id}"
	key = ENV["BING_SUBSCRIPTION_KEY"]
	puts "subscription key of #{key}"
	puts "subscription key of #{Rails.application.secrets.bing_subscription_key}"
	puts donation.inspect
	puts "Non_profit of ID #{donation.NonProfit.id}"
	uri = URI('https://api.cognitive.microsoft.com/bing/v5.0/images/search')
	uri.query = 'q='+URI::encode(donation.NonProfit.alias)+'+logo&aspect=square&size=small'

	request = Net::HTTP::Post.new(uri.request_uri)
	# Request headers
	request['Content-Type'] = 'multipart/form-data'
	# Request headers
	request['Ocp-Apim-Subscription-Key'] = ENV["BING_SUBSCRIPTION_KEY"]
	#request['Ocp-Apim-Subscription-Key'] = Rails.application.secrets.bing_subscription_key
	# Request body
	request.body = "donors choose logo"

	response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
	    http.request(request)
	end

	parsed = JSON.parse(response.body)
	done = false
	parsed["value"].each do |image|
		if done
			break
		end
		imageUrl = image["contentUrl"]
		puts "Image URL of #{imageUrl}"
		format = image["encodingFormat"]

		donation.NonProfit.image_url = format

		begin
			file = File.open(Rails.root.join('app', 'assets', 'images', 'org_logos',donation.NonProfit.id.to_s+'.'+format), 'wb' ) do |output|
			    output.write RestClient.get(imageUrl)
			    if donation.NonProfit.save
			    	puts "Org saved with ID #{donation.NonProfit.id}"
			    	done = true
			    end
			end
		rescue
			puts "Exception"
			next
		end
	end
end