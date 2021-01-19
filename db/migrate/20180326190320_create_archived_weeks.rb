class CreateArchivedWeeks < ActiveRecord::Migration[5.2]
  def change
    create_table :archived_weeks do |t|
	    t.datetime :start_date
	    t.datetime :end_date
	    t.datetime :created_at                     
	    t.datetime :updated_at                      
	    t.integer  :user_id
	    t.integer  :status_id
	    t.datetime :approved_date
	    t.integer  :approved_by
	    t.text     :comments     
	    t.string   :time_sheet
	    t.integer  :proxy_user_id
	    t.datetime :proxy_updated_date  
	    t.string  :reset_reason
      t.timestamps
    end
  end
end
