class CreateArchivedTimeEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :archived_time_entries do |t|
    		t.datetime :date_of_activity
		    t.float    :hours           
		    t.string   :activity_log     
		    t.integer  :task_id
		    t.integer  :week_id
		    t.integer  :user_id
		    t.datetime :created_at                   
		    t.datetime :updated_at                   
		    t.integer  :project_id
		    t.boolean  :sick
		    t.boolean  :personal_day
		    t.integer  :updated_by
		    t.integer  :status_id
		    t.integer  :approved_by
		    t.datetime :approved_date
		    t.time     :time_in
		    t.time     :time_out
		    t.integer  :vacation_type_id
      t.timestamps
    end
  end
end
