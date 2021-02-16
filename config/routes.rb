Rails.application.routes.draw do

  apipie
  resources :archived_time_entries, only: [:index, :show, :create]
  resources :archived_weeks, only: [:index, :show, :create]
  resources :holiday_exceptions
  resources :time_entries
  resources :weeks 
  resources :tasks
  resources :projects
  resources :customers
  resources :roles
  resources :users
  resources :holidays
  resources :employment_types
  resources :customers_holidays
  resources :report_logos
  resources :features, except: [:index]
  resources :case_studies
  resources :vacation_types
  resources :shifts
  resources :project_shifts
  resources :announcements
  #resources :analytics
  devise_for :users, :path => "account", :controllers => { passwords: 'passwords', registrations: 'registrations', invitations: 'invitations', :omniauth_callbacks => "users/omniauth_callbacks", :sessions => 'sessions' }
  # devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    match "/users/sign_in", :to => 'devise/sessions#new', via: [:get, :post]
    match "/users/sign_out", :to => 'devise/sessions#destroy', via: [:delete]
    match '/invitation/resend_invite' => 'invitations#resend_invite', via: [:post]
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  post '/weeks/:id(.:format)' => 'weeks#update'
  # You can have the root of your site routed with "root"
  authenticated :user do
    root to: 'weeks#index', as: :authenticated_root
  end
  
  get "/get_user_projects" => "users#get_user_projects"
  post '/application_versions/get_items' => "application_versions#get_items"
  get '/application_versions/delete_item' => "application_versions#delete_item" 
  post '/application_versions/edit_item' => "application_versions#edit_item"
  get '/application_versions/acknowledge_version' => "application_versions#acknowledge_version" 

  #root 'weeks#index'
  root 'static_pages#home'
  get '/about' => 'static_pages#about'
  get '/features' => 'static_pages#features'
  namespace :api do
    post 'social_login', to: "users#social_login"
    post 'login_user', to: "users#login_user"
    get 'login_user', to: "users#login_user"
    get 'get_weekly_time_entries', to: "time_entries#get_weekly_time_entries"
    get 'get_daily_time_entries', to: "time_entries#get_daily_time_entries"
    get 'submit_weekly_time_entry', to: "time_entries#submit_weekly_time_entry"
    get 'delete_time_entry', to: "time_entries#delete_time_entry"
    get 'get_time_entry_detail', to: "time_entries#get_time_entry_detail"
    post 'save_time_entry', to: "time_entries#save_time_entry"
    get 'get_user_projects', to: "time_entries#get_user_projects"
    get 'get_time_entry_status', to: "time_entries#get_time_entry_status"
    get 'get_project_tasks', to: "time_entries#get_project_tasks"
    post 'checkin_time_entry', to: "time_entries#checkin_time_entry"
    post 'checkout_time_entry', to: "time_entries#checkout_time_entry"
    post 'save_device_info', to: "notifications#save_device_info"
    get 'remove_device_info', to: "notifications#remove_device_info"
    get 'get_customer_detail', to: "users#get_customer_detail"
    get 'get_customer_holidays', to: "users#get_customer_holidays"
    get 'agree_to_terms_and_conditions', to: "users#agree_to_terms_and_conditions"

    post 'send_entry', to: "users#post_data"
    get 'send_entry', to: "users#post_data"

    get 'get_time_entry', to: "users#get_time_entry"
    post 'get_time_entry', to: "users#get_time_entry"

    get 'get_tasks', to: "users#get_tasks"
    post 'get_tasks', to: "users#get_tasks"

    post 'update_date', to: "users#update_date"
    get 'update_date', to: "users#update_date"

    post 'get_submitted_timesheet', to: "users#get_submitted_timesheet"
    get 'get_submitted_timesheet', to: "users#get_submitted_timesheet"

    post 'approve', to: "users#approve"
    get 'approve', to: "users#approve"

    post 'reject', to: "users#reject"
    get 'reject', to: "users#reject"

    post 'submit_week', to: "users#submit_week"

    resource :sessions, only: [:create, :destroy]
  end

  post 'change_status' => 'weeks#change_status', as: :change_status
  get 'duplicate' => 'weeks#duplicate'
  get 'weeks/:id/report' => 'weeks#report'
  
  get '/dynamic_project_update' => 'projects#dynamic_project_update'
  get '/dynamic_customer_update' => 'customers#dynamic_customer_update'
  post '/add_configuration' => 'projects#add_configuration', as: :add_configuration
  post '/add_configuration_customers' => 'customers#add_configuration_customers', as: :add_configuration_customers
  get '/remove_configuration' => 'projects#remove_configuration', as: :remove_configuration
  get '/refresh_task' => 'projects#refresh_task'
  

  post '/create_project_from_system' => 'projects#create_project_from_system'
  get 'show_projects/:system' => 'projects#show_projects'

  get 'projects/:id/approve/:week_id/:row_id' => 'projects#approve'
  match 'weeks/dismiss/:week_id/:row_id' => 'weeks#dismiss', via: [:get, :post]
  get 'projects/:id/reject/:week_id' => 'projects#reject'
  get 'show_project_reports' => 'projects#show_project_reports'
  post 'add_multiple_users_to_project' => "projects#add_multiple_users_to_project"
  post '/check_project_to_create_update' => 'projects#check_project_to_create_update'
  post 'remove_multiple_users_from_project' => "projects#remove_multiple_users_from_project"
  post 'shift_modal' => "projects#shift_modal"
  get 'show_shift_reports' => "shifts#show_shift_reports"
  get 'cm_shift_report' => "shifts#cm_shift_report"
  get 'shift_report/:id' => "shifts#shift_report"
  post 'shift_report/:id' => "shifts#shift_report"
  post 'show_project_reports' => 'projects#show_project_reports'
  post 'projects/:id/deactivate_project' => 'projects#deactivate_project'
  post 'projects/:id/reactivate_project' => 'projects#reactivate_project'
  post 'time_reject' => 'weeks#time_reject'
  post 'show_hours' => 'projects#show_hours'
  post '/pending_email' => 'projects#pending_email'
  post '/customers_pending_email' => 'customers#customers_pending_email'
  post '/previous_comments' => 'weeks#previous_comments'
  post '/shared_user' => 'customers#shared_user'
  get '/add_shared_users' => 'customers#add_shared_users'
  post '/assign_shift' => 'shifts#assign_shift'
  get '/toggle_shift' => 'shifts#toggle_shift'
  post '/add_previous_week' => 'weeks#add_previous_week', as: :add_previous_week
  post '/open_previous_week_modal' => 'weeks#open_previous_week_modal'

  post '/open_edit_customer_modal' => 'customers#open_edit_customer_modal'

  post '/hours_approved' => 'customers#hours_approved', as: :hours_approved
  post '/hours_submitted' => 'customers#hours_submitted', as: :hours_submitted
  get '/users_on_project' => 'customers#users_on_project', as: :users_on_project
  get '/show_pm_projects' => 'customers#show_pm_projects', as: :show_pm_projects

  get '/show_user_reports/:id' => 'users#show_user_reports'
  post '/show_user_reports/:id' => 'users#show_user_reports'

  get '/show_user_weekly_reports/:id' => 'users#show_user_weekly_reports'
  post '/show_user_weekly_reports/:id' => 'users#show_user_weekly_reports'

  get '/set_default_project' => 'users#set_default_project'
  post '/update_announcement' => 'announcements#update_announcement'

  match 'accept_terms_and_condition' => 'users#accept_terms_and_condition', via: [:get, :post]
  
  get 'add_user_to_project' => "projects#add_user_to_project"
  get '/projects/:id/user_time_report' => 'projects#user_time_report'
  match 'user_account', :to => "users#user_account",  via: [:get, :post]
  match 'admin', :to => "users#admin", via: [:get, :post]
  post 'update_front_page_content' => "features#update_front_page_content"
  get 'display_data' => "users#display_data"
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get 'remove_user_from_customer' => "customers#remove_user_from_customer"
  get 'shared_user' => "customers#shared_user"
  get 'add_pm_role' => "customers#add_pm_role"
  get 'assign_proxy_role' => "customers#assign_proxy_role"
  get 'assign_cm_proxy_role' => "customers#assign_cm_proxy_role"
  get 'edit_customer_user/:user_id' => "customers#edit_customer_user"
  get '/update_user_employment' => "customers#update_user_employment"
  get 'vacation_request' => "customers#vacation_request"
  post 'vacation_request' => "customers#vacation_request"
  get 'customers/approve_vacation/:vr_id/:row_id' => 'customers#approve_vacation'
  get 'customers/reject_vacation/:vr_id/:row_id' => 'customers#reject_vacation'
  get 'customers/approve_cancel_request/:vr_id/:row_id' => 'customers#approve_cancel_request'
  get 'resend_vacation_request' => 'customers#resend_vacation_request'
  get 'cancel_vacation_request' => 'customers#cancel_vacation_request' 
  get 'customers/:id/theme' => 'customers#set_theme'
  get 'customers/:id/clear_filter' => 'customers#clear_filter', as: :clear_filter
  get 'pre_vacation_request' => "customers#pre_vacation_request"
  get 'single_vacation_request' => "weeks#single_vacation_request"

  get 'shift_change_request' => "customers#shift_change_request"
  get 'shift_request' => 'customers#shift_request'
  get 'projects/approve_shift_change/:sr_id/:row_id/:project_id' => 'projects#approve_shift_change'
  get 'projects/reject_shift_change/:sr_id/:row_id/:project_id' => 'projects#reject_shift_change'

  # Form to reset status_id and duplicate exist
  get '/reset_timesheet/:customer_id' => 'users#reset'
  post '/reset_timesheet/:customer_id' => 'users#reset'
  get 'approved_week' => 'users#approved_week'
  post 'approved_week' => 'users#approved_week'
  get 'default_week' => 'users#default_week'

  #Questionaite
  post 'customers/questionaire' => 'customers#questionaire'
  get 'assign_report_logo_to_user' => "users#assign_report_logo_to_user"
  get 'manage_profiles' => "users#manage_profiles"
  get 'assign_project' => "users#assign_project"
  post "invite_sub_users" => "users#invite_sub_users"
  get "login_user/:id" => "users#login_user"

  get 'user_profile' => "users#user_profile"
  get 'employee_profile' => "customers#employee_profile", as: :employee_profile
  get 'user_notification' => "users#user_notification", as: :user_notification
  get 'get_notification' => "users#get_notification"
  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase
  get 'available_tasks/:id' => 'tasks#available_tasks'
  get 'available_data/:id' => 'features#available_data'
  get 'available_users/:project_id' => 'customers#available_users'
  get '/default_comment' => 'tasks#default_comment'
  
  get 'check_holidays/:id' => "holidays#check_holidays"
  post 'holidays/create' => 'holidays#create'

  #get 'customer_reports/:id' => 'customers#customer_reports'
  get 'inventory_reports/:id' => 'customers#inventory_reports'
  get 'customers/:id/customer_reports' => 'customers#customer_reports'
  get 'customers/:id/project_reports' => 'customers#project_reports'
  get 'customers/:id/inventory_reports' => 'customers#inventory_reports'
  
  get 'permission_denied' => 'projects#permission_denied'

  get "/users/:id/proxies/" => "users#proxies"
  
  get "/users/:id/proxies/:proxy_id" => "users#proxy_users"
  get "/users/:id/proxies/:proxy_id/enter_timesheets" => "users#enter_timesheets"
  get "/users/:id/proxies/:proxy_id/show_timesheet_dates" => "users#show_timesheet_dates"
  post "/users/:id/proxies/:proxy_id/fill_timesheet" => "users#fill_timesheet"
  get "/users/:id/proxies/:proxy_id/add_proxy_row" => "users#add_proxy_row", as: :add_proxy_row
  
  get "/users/:user_id/proxies/:proxy_id/proxy_users/:proxy_user" => "weeks#proxy_week"
  
  post "/users/invite_customer" => "users#invite_customer"
  
  post "/customers/invite_to_project" => "customers#invite_to_project"
  post "project/:project_id/add_adhoc_pm" => "projects#add_adhoc_pm", as: :add_adhoc_pm
  post "customer/:customer_id/add_adhoc_pm_by_cm" => "customers#add_adhoc_pm_by_cm", as: :add_adhoc_pm_by_cm
  get "/copy_timesheet/:id" => "weeks#copy_timesheet"
  post "/time_entry_week_hours" => "weeks#time_entry_week_hours"
  
  get "/show_all_projects" => "projects#show_all_projects"
  post "assign_employment_types/" => "customers#assign_employment_types", as: :assign_employment_types
  post "assign_pm/:id" => "customers#assign_pm", as: :assign_pm
  get "/clear_timesheet/:id" => "weeks#clear_timesheet"
  get "/show_old_timesheets" => "projects#show_old_timesheets"
  get "/show_all_timesheets" => "weeks#show_all_timesheets"
  post "/add_previous_comments" => "weeks#add_previous_comments", as: :add_previous_comments
  get 'remove_emp_from_vacation' => "customers#remove_emp_from_vacation"
  match "/expense_records" => 'weeks#expense_records', via: [:get, :post]
  get '/delete_expense' => "weeks#delete_expense"
  get '/delete_attachment' => "weeks#delete_attachment"
  get '/edit_expense' => "weeks#edit_expense"
  post "/add_expense_records" => "weeks#add_expense_records"
  get 'get_employment/' => 'customers#get_employment'

  get "analytics/vacation_reports/customer/:customer_id" => 'analytics#vacation_report'
  get "/analytics/user_activities/:customer_id" => 'analytics#user_activities' 
  get "analytics/vacation_types_summary/:customer_id" => 'analytics#vacation_types_summary' 
  post "analytics/vacation_types_summary/:customer_id" => 'analytics#vacation_types_summary' 
  get 'user_summary' => "analytics#user_summary"

  match "customers/:id/analytics" => 'analytics#customer_reports', via: [:get, :post]
  match "customers/:id/analytics" => 'analytics#inventory_reports', via: [:get, :post] 
  post "/bar_graph" => 'analytics#bar_graph'
  match "analytics/:customer_id" => "analytics#index", via: [:get, :post]
  match "users_notification_date" => "users#user_notification_date", via: [:get, :post]
  match "add_multiple_user_recommendation" => "users#add_multiple_user_recommendation", via: [:get, :post]
  match "add_multiple_user_disciplinary" => "users#add_multiple_user_disciplinary", via: [:get, :post]
  match "add_multiple_user_inventory" => "users#add_multiple_user_inventory", via: [:get,:post]
  get 'set_selected_users' => 'projects#set_selected_users'
  get 'set_inventory_submitted_date' => 'users#set_inventory_submitted_date', via: [:get,:post]
  get 'inventory_and_equipment_reports' => 'projects#inventory_and_equipment_reports', via: [:get,:post]
  get 'send_project_users_email' => "projects#send_project_users_email", via: [:get,:post]
  post 'add_multiple_users_to_send_email' => "projects#add_multiple_users_to_send_email"

  get '/privacy' => 'static_pages#privacy'
  get '/terms_of_service' => 'static_pages#terms_of_service'
  post '/contact_form_mail' => 'static_pages#contact_form_mail'
  
  match "approve_all" => "projects#approve_all", via: [:get, :post]
  mount Ckeditor::Engine => '/ckeditor'

  mount SessionTimeoutPrompter::Engine, at: "/session_timeout_prompter"
  
  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
