class VacationRequest < ApplicationRecord
	has_many :users
	has_many :customers
	belongs_to :vacation_type
end