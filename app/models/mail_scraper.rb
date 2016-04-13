require 'cgi' 
require 'date'

filename = ARGV[0]
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


puts 'FROM EMAIL OF '+from_email.to_s

if org_domain == "rally.org"
	org_name_match = stripped_content.scan(/Subject: Thanks for your gift to (.+)!/)
	#org_name = org_name_match
	puts 'ORG NAME OF '+ org_name_match[0][0].to_s
elsif org_domain =='paypal.com'
	org_name_match = stripped_content.scan(/Subject: Receipt for your donation to (.+)/)
	#org_name = org_name_match
	puts 'ORG NAME OF '+ org_name_match[0][0].to_s
end

if org_name_match
	org_name = org_name_match[0][0].to_s
end

donations = Donation.all

if defined?(org_domain)
	@org = ::NonProfit.find_by(domain_name: org_domain)
elsif defined?(org_name)
	@org = ::NonProfit.find_by(name: org_name)
else
	puts "No org found"
end 

puts "Org #{org.name}"

to_match = stripped_content.scan(/To: "?.*"?\s*<(\w+@\w+\.\w{3})>/)

if to_match.length > 1
	puts 'More than 1 match for To regex'
end
to_email = to_match[0][0]
puts 'TO EMAIL OF '+to_email.to_s

user = Users.find_by email: to_email

if user.nil?
	#obviously change password at some point...should create random value and send email to user
	user = User.new(:email => to_email,:password_digest => 'changeme123')
	if not(user.save)
		puts "Error saving user"
	end
end

date_match = stripped_content.scan(/Date: (.*)/)
date_stripped = date_match[0][0]
puts date_stripped
date = Date.strptime(date_stripped,'%b %d, %Y %l:%M %p')
puts date

amount_match = stripped_content.scan(/\$\d+\.00/)

if amount_match.length > 1
	puts 'More than 1 match for Amount regex'
end

amount_raw = amount_match[0]
amount_num = amount_raw[1..-1].to_f

puts 'AMOUNT NUM OF '+amount_num.to_s

donation = Donation.new(:amount => amount_num, :donation_date => date, :NonProfit => org, :User => user)

if not(donation.valid?)
	puts "Donation not valid"
end
if not(donation.save)
	puts "Error saving donation"
end


