require 'ruby-web-search'

response = RubyWebSearch::Google.search(:query => "charity: water")
print response.result