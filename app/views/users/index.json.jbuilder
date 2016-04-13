json.array!(@users) do |user|
  json.extract! user, :id, :email, :password, :income
  json.url user_url(user, format: :json)
end
