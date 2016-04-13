json.array!(@processors) do |processor|
  json.extract! processor, :id, :name, :domain, :regex
  json.url processor_url(processor, format: :json)
end
