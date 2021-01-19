class Holiday < ApplicationRecord
  has_and_belongs_to_many :customers, join_table: :customers_holidays
end
