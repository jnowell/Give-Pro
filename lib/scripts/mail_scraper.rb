require 'cgi' 
require 'date'
require 'curb'
require 'uri/http'
require 'searchbing'

class ImageScraper
	def self.parse_email(filename)
		filename = filename.to_s
		puts 'File of '+filename
		file = File.open(filename, "rb")
		contents = file.read
		#puts contents
		stripped_content_index = contents.index('---------- Forwarded message ----------')
		#puts stripped_content_index
		stripped_content = contents[stripped_content_index..-1]
		#puts stripped_content
		#stripped_content = CGI::unescapeHTML(contents.gsub(/.*---------- Forwarded message ----------/m,"\n"))
		#puts 'STRIPPED CONTENT OF '+stripped_content
		#From: "Rally" <team@rally.org>
		from_match = stripped_content.scan(/From: "?.*"?\s*<(\w+@\w+\.\w{3})>/)
		#from_match = from_regex.match(stripped_content)
		if from_match.length > 1
			puts 'More than 1 match for From regex'
		end
		from_email = from_match[0][0].to_s
		org_domain = from_email.split("@").last

		if org_domain == "rally.org"
			processor = ::Processor.find_by(domain_name: "rally.org")
			org_name_match = stripped_content.scan(/Subject: Thanks for your gift to (.+)!/)
			#org_name = org_name_match
			puts 'ORG NAME OF '+ org_name_match[0][0].to_s
		elsif org_domain =='paypal.com'
			processor = ::Processor.find_by(domain_name: "paypal.com")
			org_name_match = stripped_content.scan(/Subject: Receipt for your donation to (.+)/)
			#org_name = org_name_match
			puts 'ORG NAME OF '+ org_name_match[0][0].to_s
		elsif org_domain =='actblue.com'
			org_name_match = stripped_content.scan(/my campaign for the (\w+)\./)
			puts 'ORG NAME OF '+ org_name_match[0][0].to_s
		end

		if org_name_match
			org_name = org_name_match[0][0].to_s
		end

		puts "Org domain of #{org_domain} and org name of #{org_name}"

		if defined?(org_name)
			org = ::NonProfit.find_by(name: org_name)
		elsif defined? org_domain
			org = ::NonProfit.find_by(domain_name: org_domain)
		else
			puts "No org found"
			exit(false)
		end 

		puts "Org #{org.name}"

		if stripped_content.match(/To: \S* <.*>/)
			puts "Scanning 1"
			to_match = stripped_content.scan(/To: "?.*"?\s?<?(\w+@\w+\.\w{3})>?/)
		else
			puts "Scanning 2"
			to_match = stripped_content.scan(/To: (\w+@\w+\.\w{3})/)
		end

		if to_match.length > 1
			puts 'More than 1 match for To regex '+to_match.length.to_s
		end

		to_email = to_match[0][0]
		puts 'TO EMAIL OF '+to_email.to_s

		user = ::User.find_by(email: to_email)

		if user.nil?
			user = User.new(:email => to_email)
			unless user.valid?
				user.errors.full_messages.each do |message|
		            puts message
		        end
		    end
		    if user.save
				puts "User created with ID #{user.id}"
			else
				puts "Error saving user"
			end
		end

		date_match = stripped_content.scan(/Date: (.*)/)
		date_stripped = date_match[0][0]
		begin
			date = Date.strptime(date_stripped,'%b %d, %Y %l:%M %p')
		rescue ArgumentError
			date = Date.strptime(date_stripped,'%a, %b %d, %Y at %l:%M %p')
		end

		if org.amount_regex.empty?
			amount_regex = '\$(\d+)\.00'
		else
			amount_regex = org.amount_regex
		end

		puts "AMOUNT REGEX of "+amount_regex

		amount_match = stripped_content.scan(/#{amount_regex}/)

		if (amount_match.length > 1 or amount_match.length == 0)
			puts 'Unable to parse amount using Regex'
			send_no_amount_email(stripped_content,org)
			exit(false)
		end

		amount_num = amount_match[0][0].to_f
		
		donation = Donation.new(:amount => amount_num, :donation_date => date, :NonProfit => org, :User => user, :Processor => processor)

		unless donation.valid?
			puts "Donation not valid"
		end

		if donation.save
			puts "Donation created with ID #{donation.id}"
		else
			puts "Error saving donation"
		end

		if org.image_url.blank?
			find_non_profit_url(org)
		end
	end

	def self.find_non_profit_image(org)
		easy = Curl::Easy.new
		easy.follow_location = true
		easy.max_redirects = 3 
		easy.url = org.domain_name

		easy.perform

		content = easy.body_str

		image_match = content.scan(/<meta property="og:image" content="([^"]*)" \/>/)

		share_image = image_match[0][0]

		org.image_url = share_image

		if org.save
			puts "Image with URL #{share_image} added to non-profit #{org.id}"
		else
			puts "Error adding image to non-profit"
		end
	end

	def self.find_non_profit_url(org)
		bing_search = Bing.new('ATVDIsAQPq3pWnp5ody9Ri1bFIL6MXJOubZzHcx2xRQ',10,'WebOnly')

		bing_results = bing_search.search(org.name)

		uri = URI.parse(bing_results[0][:Url])
		domain = PublicSuffix.parse(uri.host)

		org.domain_name = domain.domain

		if org.save
			puts "Domain name #{org.domain_name} added to non-profit #{org.id}"
		else
			puts "Error saving domain name to non-profit"
		end
	end

	def self.send_no_amount_email(email_content,org)
		intro_text = "Our script was unable to determine the donation amount in the following email. Please find a suitable regex and then edit the Regex field in <a href=\"http://www.givepro.io/non_profits/#{org.id}/edit\">this form</a> and click 'Submit'."
		ses = AWS::SES::Base.new(
	  		:access_key_id => 'AKIAIR4XE2SLCCOOH4DA',
	  		:secret_access_key => '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')

		print ses.addresses.list.result
		
		ses.send_email(
	            :to        => ['jrnowell@gmail.com'],
	            :source    => '"GivePro" <charityemailtest@gmail.com>',
	            :subject   => 'Script Error: Unable to Determine Amount',
	            :html_body => intro_text + "<br/>"+CGI.unescape_html(email_content)
		)
	end
end

ImageScraper.parse_email(ARGV[0])
