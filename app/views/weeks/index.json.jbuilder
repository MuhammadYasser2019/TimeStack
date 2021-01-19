json.array!(@weeks) do |week|
  json.extract! week, :id, :start_date, :end_date
  json.url week_url(week, format: :json)
end
