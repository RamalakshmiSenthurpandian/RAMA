json.array!(@users) do |user|
  json.extract! user, :id, :name, :emp_no, :dept, :address
  json.url user_url(user, format: :json)
end
