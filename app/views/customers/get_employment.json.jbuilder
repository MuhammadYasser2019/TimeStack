json.array!(@emp) do |emp|
  json.extract! emp, :id, :name
  json.url employment_type_url(emp, format: :json)
end
