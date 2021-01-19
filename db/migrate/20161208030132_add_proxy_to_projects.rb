class AddProxyToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :proxy, :integer
  end
end
