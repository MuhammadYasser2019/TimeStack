json.array!(@tasks) do |task|
  json.extract! task, :id, :code, :description
  json.url task_url(task, format: :json)
end
