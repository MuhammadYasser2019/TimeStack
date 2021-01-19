FactoryBot.define do
  factory :time_entry do
    date {DateTime.now}
    hours 1
    comments "MyString"
    task nil
    week nil
    user nil
  end
end
