class VacationType < ApplicationRecord

	has_many :employment_types_vacation_types
	has_many :employment_types, through: :employment_types_vacation_types
end
