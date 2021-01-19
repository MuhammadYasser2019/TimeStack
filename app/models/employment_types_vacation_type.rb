class EmploymentTypesVacationType < ApplicationRecord
	belongs_to :employment_type
	belongs_to :vacation_type
end
