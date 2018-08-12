require 'curb'
require 'curl'
require 'net/http'
require 'open-uri'
require 'rest_client'

non_profits = NonProfit.where.not('domain_name' => nil)

orgs_saved = 0

for org in non_profits
	#puts "Domain name of #{org.domain_name} and ID #{org.id}"

	unless (org.id ==1) and org.domain_name and (org.domain_name.length > 0)
		next
	end

	#easy = Curl::Easy.new("http://www.google.com")
	#easy.follow_location = true
	#easy.max_redirects = 3 
	#easy.url = org.domain_name
	#easy.url = "http://www.givedirectly.org"

	#easy.perform

	#content = easy.body_str

	#there HAS to be an easier way to do this, but whatever, it works
	res = Net::HTTP.get_response(URI('http://www.givedirectly.org'))
	puts res.code
	while ((res.code == '301') or (res.code == '302')) do
		puts res['location']
		res = Net::HTTP.get_response(URI(res['location']))
	end
	content = res.body

	#request_url = 'https://www.givedirectly.org'
    #content =  Curl::Easy.http_get(request_url) {
    #	follow_location = true
    #}.body_str
    #result.follow_location = true
	#result.max_redirects = 3 
    #@body = c.body_str

	#puts "Content of #{content}"

	share_image = nil

	#image_match = content.scan(/<meta property="og:image" content="([^"]*)" \/>/)

	#<link rel="icon" type="image/icon" href="/img/web_favicon_16px.png">

	image_match = content.scan(/<link rel="(shortcut )?icon" (type="[\w\/]*" )?href="([\w.\/]*)"\/?>/)

	puts "Image match of #{image_match}"
	if image_match.length > 0
		puts "Image match of #{image_match}"
		share_image = image_match[0][2]
	end

	puts "Share image of #{share_image}"

	unless share_image
		share_image = org.domain_name+"favicon.ico"
	end

	org.image_url = share_image

	file = File.open(Rails.root.join('app', 'assets', 'images', File.basename(share_image)), 'wb' ) do |output|
    	output.write RestClient.get('https://www.givedirectly.org' + share_image)
  	end

	#download = open('https://www.givedirectly.org' + share_image)
	#IO.copy_stream(download, '/Users/jnowell/donation_tracker/app/assets/images/org_favicons/'+File.basename(share_image))

	if false
		puts "Image with URL #{share_image} added to non-profit #{org.id}"
	else
		puts "Error adding image to non-profit"
	end
end