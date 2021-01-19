json.array!(@feature) do |feature|
  json.extract! feature, :id, :feature_data, :feature_type
  json.url feature_url(feature, format: :json)
end
