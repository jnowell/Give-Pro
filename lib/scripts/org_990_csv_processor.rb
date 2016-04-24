require 'csv'

filename = ARGV[0].to_s

org_count = 0
saved_count = 0
header = true

CSV.foreach(filename) do |row|
	#disregard header row
	if header
		header = false
		next
	end
	org_count += 1
	if (org_count < 0)
		next
	end
	ein = row[0]
	name = row[1].titleize
	address = row[3].titleize
	city = row[4].titleize
	state = row[5]
	zip = row[6]
	subsection = row[8]
	classification = row[10]
	ruling = row[11]
	
	if (ruling.to_i != 0)
		#some dates are in form 'YYYY00', have to deal with that
		if (ruling.end_with? "00")
			ruling_date = Date.strptime(ruling[0..3],"%Y")
		else
			ruling_date = Date.strptime(ruling,'%Y%m')
		end
	end
	exemption = row[12]
	foundation_code = row[13]
	org = NonProfit.new(:ein => ein, :name => name, :alias => name, :address => address, :city => city, :state => state, :zip => zip, :subsection => subsection, :classification => classification, :ruling_date => ruling_date, :exemption_code => exemption, :foundation_code => foundation_code)
  	if org.save
  		saved_count += 1
  	else
  		puts "Error saving non-profit...saved count up to #{saved_count}"
  		exit(1)
  	end
  	#puts "Saved record #{saved_count}"
  	if (saved_count % 1000) == 0
  		puts "Saved record #{saved_count}"
  	end
end