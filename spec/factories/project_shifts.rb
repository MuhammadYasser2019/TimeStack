FactoryBot.define do
  factory :project_shift do
    shift_id { 1 }
    capacity { 1 }
    location { "Mexico City, Mexico" }
    shift_supervisor_id { 1 }
  end
end
