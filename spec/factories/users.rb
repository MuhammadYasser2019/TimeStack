FactoryBot.define do
  factory :user do
    sequence :email do |n|
    	"dummyEmail#{n}@gmail.com"
    end 
    password "secretPassword"
    password_confirmation "secretPassword"
    pm true
    cm true
    admin true
    user true
  end
end
