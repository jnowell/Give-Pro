json.array!(@non_profits) do |non_profit|
  json.extract! non_profit, :id, :ein, :name, :alias, :domain_name, :status_code, :donation_page_url, :image_url
  json.url non_profit_url(non_profit, format: :json)
end
