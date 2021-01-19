class CustomersHoliday < ApplicationRecord
  serialize :exceptions, Array
  belongs_to :holiday
end