class EmploymentType < ApplicationRecord

	has_many :employment_types_vacation_types, dependent: :destroy
	has_many :vacation_types, through: :employment_types_vacation_types
end
