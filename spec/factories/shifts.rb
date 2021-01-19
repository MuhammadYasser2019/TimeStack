FactoryBot.define do
  factory :shift do
    name { "MyString" }
    start_time { "2020-04-06 09:00:00" }
    end_time { "2020-04-06 17:00:00" }
    regular_hours { 8.0 }
    incharge { "MyString" }
    active { false }
    default { false }
    location { "MyString" }
    capacity { 1 }
    customer_id { 1 }
  end
end
