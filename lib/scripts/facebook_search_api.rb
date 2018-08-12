require 'net/http'
require 'json'
require 'open-uri'
require 'rest-client'

donations = Donation.joins(:NonProfit)

for donation in donations
	if donation.NonProfit.image_url.present?
		#next
	end
	puts "Donation of ID #{donation.id}"
	puts "Non profit alias of #{donation.NonProfit.alias}"
	puts "Non_profit of ID #{donation.NonProfit.id}"
	uri = URI('https://graph.facebook.com/search')
	uri.query = 'q='+URI::encode(donation.NonProfit.alias)+'+&type=page&access_token=[REDACTED]'

	request = Net::HTTP::Post.new(uri.request_uri)
	# Request headers
	request['Content-Type'] = 'multipart/form-data'
	#request['Ocp-Apim-Subscription-Key'] = Rails.application.secrets.bing_subscription_key
	# Request body
	request.body = "donors choose logo"

	response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
	    http.request(request)
	end

	parsed = JSON.parse(response.body)

	image = parsed["value"].first
	imageUrl = image["contentUrl"]
	format = image["encodingFormat"]

	donation.NonProfit.image_url = format

	file = File.open(Rails.root.join('app', 'assets', 'images', 'org_logos',donation.NonProfit.id.to_s+'.'+format), 'wb' ) do |output|
	    output.write RestClient.get(imageUrl)
	    if donation.NonProfit.save
	    	puts "Org saved with ID #{donation.NonProfit.id}"
	    end
	end
end