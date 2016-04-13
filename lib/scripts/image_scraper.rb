require 'curb'

easy = Curl::Easy.new
easy.follow_location = true
easy.max_redirects = 3 
easy.url = "charitywater.org"

easy.perform

content = easy.body_str

image_match = content.scan(/<meta property="og:image" content="([^"]*)" \/>/)

share_image = image_match[0][0]

puts share_image