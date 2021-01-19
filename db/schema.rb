# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_19_132622) do

  create_table "application_versions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "version_name"
    t.date "start_date"
    t.string "platform"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "archived_time_entries", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "date_of_activity"
    t.float "hours"
    t.string "activity_log"
    t.integer "task_id"
    t.integer "week_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_id"
    t.boolean "sick"
    t.boolean "personal_day"
    t.integer "updated_by"
    t.integer "status_id"
    t.integer "approved_by"
    t.datetime "approved_date"
    t.time "time_in"
    t.time "time_out"
    t.integer "vacation_type_id"
  end

  create_table "archived_weeks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "status_id"
    t.datetime "approved_date"
    t.integer "approved_by"
    t.text "comments"
    t.string "time_sheet"
    t.integer "proxy_user_id"
    t.datetime "proxy_updated_date"
    t.string "reset_reason"
    t.integer "week_id"
    t.integer "reset_by"
    t.datetime "reset_date"
  end

  create_table "case_studies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "case_study_name"
    t.text "case_study_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ckeditor_assets", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "data_file_name", null: false
    t.string "data_content_type"
    t.integer "data_file_size"
    t.string "type", limit: 30
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type"], name: "index_ckeditor_assets_on_type"
  end

  create_table "customers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zipcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "theme"
    t.string "logo"
    t.decimal "regular_hours", precision: 10, default: "8"
  end

  create_table "customers_holidays", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "customer_id"
    t.integer "holiday_id"
    t.index ["customer_id", "holiday_id"], name: "index_customers_holidays_on_customer_id_and_holiday_id"
    t.index ["holiday_id", "customer_id"], name: "index_customers_holidays_on_holiday_id_and_customer_id"
  end

  create_table "default_reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "customer_id"
    t.integer "project_id"
    t.integer "user_id"
    t.date "start_date"
    t.date "end_date"
    t.string "month"
    t.boolean "current_week"
    t.boolean "exclude_pending_user"
    t.boolean "billable"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employment_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "customer_id"
  end

  create_table "employment_types_vacation_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "employment_type_id"
    t.integer "vacation_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "expense_records", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "expense_type"
    t.text "description"
    t.date "date"
    t.integer "amount"
    t.string "attachment"
    t.integer "project_id"
    t.integer "week_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "external_configurations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "customer_id"
    t.string "system_type"
    t.string "url"
    t.string "jira_email"
    t.string "password"
    t.string "confirm_password"
    t.integer "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "features", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "feature_type"
    t.text "feature_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "holiday_exceptions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "project_id"
    t.integer "customer_id"
    t.text "holiday_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "holidays", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.boolean "global"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date"
  end

  create_table "project_shifts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "shift_id"
    t.integer "capacity"
    t.string "location"
    t.integer "shift_supervisor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_id"
  end

  create_table "projects", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "proxy"
    t.boolean "inactive"
    t.integer "adhoc_pm_id"
    t.datetime "adhoc_start_date"
    t.datetime "adhoc_end_date"
    t.boolean "deactivate_notifications", default: false
    t.integer "external_type_id"
    t.index ["customer_id"], name: "index_projects_on_customer_id"
  end

  create_table "projects_users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "active"
    t.integer "project_shift_id"
    t.datetime "sepration_date"
    t.index ["project_id"], name: "index_projects_users_on_project_id"
    t.index ["user_id"], name: "index_projects_users_on_user_id"
  end

  create_table "report_logos", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "report_logo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles_users", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
    t.index ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id"
  end

  create_table "shared_employees", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "customer_id"
    t.boolean "permanent", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shifts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "start_time"
    t.string "end_time"
    t.float "regular_hours"
    t.string "incharge"
    t.boolean "active"
    t.boolean "default"
    t.string "location"
    t.integer "capacity"
    t.integer "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "shift_supervisor_id"
    t.boolean "mon", default: false
    t.boolean "tue", default: false
    t.boolean "wed", default: false
    t.boolean "thu", default: false
    t.boolean "fri", default: false
    t.boolean "sat", default: false
    t.boolean "sun", default: false
  end

  create_table "statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "default_comment"
    t.boolean "active"
    t.boolean "billable", default: false
    t.integer "imported_from"
    t.index ["project_id"], name: "index_tasks_on_project_id"
  end

  create_table "time_entries", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.datetime "date_of_activity"
    t.float "hours"
    t.string "activity_log", limit: 500
    t.integer "task_id"
    t.integer "week_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "project_id"
    t.boolean "sick"
    t.boolean "personal_day"
    t.integer "updated_by"
    t.integer "status_id"
    t.integer "approved_by"
    t.datetime "approved_date"
    t.time "time_in"
    t.time "time_out"
    t.integer "vacation_type_id"
    t.string "partial_day"
    t.integer "project_shift_id"
    t.index ["task_id"], name: "index_time_entries_on_task_id"
    t.index ["user_id"], name: "index_time_entries_on_user_id"
    t.index ["week_id"], name: "index_time_entries_on_week_id"
  end

  create_table "upload_timesheets", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "week_id"
    t.string "time_sheet"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_devices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "user_token"
    t.string "device_id"
    t.string "platform"
    t.string "device_name"
    t.index ["user_id"], name: "index_user_devices_on_user_id"
  end

  create_table "user_disciplinaries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "project_id"
    t.string "disciplinary"
    t.integer "submitted_by"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_disciplinaries_on_user_id"
  end

  create_table "user_inventory_and_equipments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "issued_by"
    t.string "equipment_name"
    t.string "equipment_number"
    t.datetime "issued_date"
    t.datetime "submitted_date"
    t.integer "project_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_inventory_and_equipments_on_user_id"
  end

  create_table "user_notifications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "notification_type"
    t.text "body"
    t.integer "count"
    t.boolean "seen", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "week_id"
  end

  create_table "user_recommendations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "project_id"
    t.string "recommendation"
    t.integer "submitted_by"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_recommendations_on_user_id"
  end

  create_table "user_roles", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id"
  end

  create_table "user_vacation_tables", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "vacation_id"
    t.decimal "days_used", precision: 5, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_week_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "status_id"
    t.integer "week_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_week_statuses_on_user_id"
    t.index ["week_id"], name: "index_user_week_statuses_on_week_id"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "provider"
    t.string "uid"
    t.datetime "oauth_expires_at"
    t.string "name"
    t.string "oauth_token"
    t.boolean "pm"
    t.boolean "cm"
    t.boolean "admin"
    t.boolean "user"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.integer "invited_by_id"
    t.string "invited_by_type"
    t.integer "invitations_count", default: 0
    t.boolean "google_account"
    t.boolean "proxy"
    t.integer "customer_id"
    t.datetime "vacation_start_date"
    t.datetime "vacation_end_date"
    t.integer "report_logo"
    t.integer "default_project"
    t.integer "default_task"
    t.integer "employment_type"
    t.datetime "invitation_start_date"
    t.boolean "shared"
    t.string "authentication_token", limit: 30
    t.boolean "is_active", default: true
    t.integer "parent_user_id"
    t.string "image"
    t.string "emergency_contact"
    t.datetime "inactive_at"
    t.boolean "terms_and_condition", default: false
    t.boolean "proxy_cm", default: false
    t.datetime "password_changed_at"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invitations_count"], name: "index_users_on_invitations_count"
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["password_changed_at"], name: "index_users_on_password_changed_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_application_versions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "application_version_id"
  end

  create_table "vacation_requests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "customer_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "vacation_start_date"
    t.datetime "vacation_end_date"
    t.integer "sick", limit: 1
    t.integer "personal", limit: 1
    t.string "status"
    t.text "comment"
    t.integer "vacation_type_id"
    t.string "partial_day"
    t.decimal "hours_used", precision: 5, scale: 2
    t.index ["customer_id"], name: "index_vacation_requests_on_customer_id"
    t.index ["user_id"], name: "index_vacation_requests_on_user_id"
  end

  create_table "vacation_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "customer_id"
    t.string "employment_type"
    t.string "vacation_title"
    t.integer "max_days"
    t.boolean "rollover"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "paid"
    t.integer "vacation_bank"
    t.boolean "accrual"
  end

  create_table "weeks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "status_id"
    t.datetime "approved_date"
    t.integer "approved_by"
    t.text "comments"
    t.string "time_sheet"
    t.integer "proxy_user_id"
    t.datetime "proxy_updated_date"
    t.boolean "dismiss", default: false
  end

  add_foreign_key "projects", "customers"
  add_foreign_key "tasks", "projects"
  add_foreign_key "time_entries", "tasks"
  add_foreign_key "time_entries", "users"
  add_foreign_key "time_entries", "weeks"
  add_foreign_key "user_devices", "users"
end
