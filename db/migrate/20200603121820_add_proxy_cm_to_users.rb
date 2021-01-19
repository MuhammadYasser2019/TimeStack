class AddProxyCmToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :proxy_cm, :boolean, :default => false
  end
end
