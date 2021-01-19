json.array!(@time_entries) do |time_entry|
  json.extract! time_entry, :id, :date, :hours, :activity_log, :task_id, :week_id, :user_id
  json.url time_entry_url(time_entry, format: :json)
end
