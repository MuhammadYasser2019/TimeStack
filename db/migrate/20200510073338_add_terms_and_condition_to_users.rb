class AddTermsAndConditionToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :terms_and_condition, :boolean, :default => false
  end
end
