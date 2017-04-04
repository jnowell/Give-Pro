require 'cgi' 
require 'date'
require 'curb'
require 'uri/http'
require 'searchbing'
require 'aws-sdk'

class MailScraper
	def self.parse_raw_content(contents)
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

		to_email = to_match[0][0].to_s

		date_match = stripped_content.scan(/Date: (.*)/)
		date_stripped = date_match[0][0]
		begin
			date = Date.strptime(date_stripped,'%b %d, %Y %l:%M %p')
		rescue ArgumentError
			date = Date.strptime(date_stripped,'%a, %b %d, %Y at %l:%M %p')
		end

		parse_email(stripped_content, nil, from_email, to_email)
	end

	def self.parse_email(content, subject, from_email, to_email, date)
		org_domain = from_email.split("@").last

		processor = ::Processor.find_by(domain: org_domain)

		if processor
			org_name_match = subject.scan(/#{processor.regex}/)
			unless org_name_match.exists?
				org_name_match = content.scan(/#{processor.regex})/)	
			end
			if org_name_match
				org_name = org_name_match[0][0].to_s
			end
		end

		
		#if org_domain == "rally.org"
		#	processor = ::Processor.find_by(domain_name: "rally.org")
		#	org_name_match = subject.scan(/Thanks for your gift to (.+)!/)
		#	#org_name = org_name_match
		#	puts 'ORG NAME OF '+ org_name_match[0][0].to_s
		#elsif org_domain =='paypal.com'
		#	processor = ::Processor.find_by(domain_name: "paypal.com")
		#	org_name_match = subject.scan(/Receipt for your donation to (.+)/)
		#	#org_name = org_name_match
		#	puts 'ORG NAME OF '+ org_name_match[0][0].to_s
		#elsif org_domain =='actblue.com'
		#	org_name_match = content.scan(/my campaign for the (\w+)\./)
		#	puts 'ORG NAME OF '+ org_name_match[0][0].to_s
		#end
		
		

		puts "Org domain of #{org_domain} and org name of #{org_name}"

		if org_name
			org = ::NonProfit.find_by(name: org_name)
		elsif !org_domain.empty?
			org = ::NonProfit.find_by(domain_name: org_domain)
		end

		puts "Org of #{org}"

		unless org.present?
			puts "No org found"
			unless processor.present?
				return false
			end
		end 

		user = ::User.find_by(email: to_email)

		puts "USER OF #{user}"

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

		unless org.amount_regex.present?
			amount_regex = '\$(\d+)\.00'
		else
			amount_regex = org.amount_regex
		end

		puts "AMOUNT REGEX of "+amount_regex

		amount_match = content.scan(/#{amount_regex}/)

		if (amount_match.length > 1 or amount_match.length == 0)
			puts 'Unable to parse amount using Regex'
			send_no_amount_email(content,org)
			return false
		end

		puts "AMOUNT MATCH OF #{amount_match}"

		amount_num = amount_match[0][0].to_f

		puts "AMOUNT NUM OF #{amount_num}"
		if org
			non_profit_string = org.alias
		elsif processor
			non_profit_string = processor.name
		end
		
		donation = Donation.new(:amount => amount_num, :donation_date => date, :non_profit_string => non_profit_string, :NonProfit => org, :User => user, :Processor => processor)

		unless donation.valid?
			puts "Donation not valid"
		end

		if donation.save
			puts "Donation created with ID #{donation.id}"
			if org.homepage.blank?
				#find_non_profit_url(org)
			end
			return true
		else
			puts "Error saving donation"
			return false
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
		bing_search = Bing.new('',10,'WebOnly')

		bing_results = bing_search.search(org.name)

		uri = URI.parse(bing_results[0][:Url])
		domain = PublicSuffix.parse(uri.host)

		org.homepage = uri
		org.domain_name = domain.domain

		if org.save
			puts "Homepage #{org.homepage} and domain name #{org.domain_name} added to non-profit #{org.id}"
		else
			puts "Error saving domain name to non-profit"
		end
	end

	def self.send_no_amount_email(email_content,org)
		#puts "AWS KEY id of "+.to_s
		#intro_text = "Our script was unable to determine the donation amount in the following email. Please find a suitable regex and then edit the Regex field in <a href=\"http://www.givepro.io/non_profits/#{org.id}/edit\">this form</a> and click 'Submit'."
		intro_text = "Our script was unable to determine the donation amount in the following email. Please find a suitable regex"

		ses = AWS::SES::Base.new(
	  		:access_key_id => ENV["AWS_ACCESS_KEY_ID"],
	  		:secret_access_key => ENV["AWS_SECRET_KEY"])

		#print ses.buckets
		
		
		ses.send_email(
	            :to        => ['jrnowell@gmail.com'],
	            :source    => 'postmaster@givepro.io',
	            :subject   => 'Script Error: Unable to Determine Amount',
	            :html_body => intro_text + "<br/>"+CGI.unescape_html(email_content)
		)
		
	end
end

if ARGV[0]
  filename = ARGV[0]
  filename = filename.to_s
  puts 'File of '+filename
  file = File.open(filename, "rb")
  contents = file.read
  MailScraper.parse_raw_content(contents)
end
