class UserDevice < ApplicationRecord
    has_one :user

    def self.save_device_information(user_id, device_id, platform, device_name,token)
        @user_device = UserDevice.where(:device_id => device_id, :user_id => user_id).first                

        if @user_device.nil?
            @user_device = UserDevice.new
            @user_device.user_id = user_id
            @user_device.device_id = device_id
            @user_device.user_token = token
            @user_device.platform = platform
            @user_device.save
        else
            @user_device.user_token = token
            @user_device.save
        end
      
        UserDevice.where("user_id != ? AND device_id=?",user_id,device_id).update_all(user_token: nil)
    end

    def self.send_shift_notification
        time_zone = 'Eastern Time (US & Canada)'
        check_start_time = Time.now.in_time_zone(time_zone).time

        week_day = check_start_time.wday
        if week_day == 0 || week_day == 6 #Sunday and Saturday
            return nil
        end            

        check_end_time = check_start_time +15 * 60 #15 min later

        shifts = Shift.select(:start_time, :end_time, :id)

        starting_shift_ids = []
        ending_shift_ids = []

        shifts.map do |s|
            start_time = s.start_time.to_time
            end_time = s.end_time.to_time

            between_start = start_time>=check_start_time && start_time<=check_end_time
            between_end = end_time>=check_start_time && end_time<=check_end_time
            if between_start
                starting_shift_ids.push(s.id)
            elsif between_end
                ending_shift_ids.push(s.id)
            end
        end

        if starting_shift_ids.size > 0
            UserDevice.handle_shift_notification(starting_shift_ids, true)
        end

        if ending_shift_ids.size > 0
            UserDevice.handle_shift_notification(ending_shift_ids, false)
        end
    end

    private 

    def self.handle_shift_notification(shift_ids, starting_shift)
        project_shift_ids = ProjectShift.where(:shift_id=>shift_ids).pluck(:id)

        shift_projects = ProjectsUser.where(:project_shift_id=> project_shift_ids, :current_shift=> true).joins(:user, :project).where(:projects=>{inactive:[0,nil], deactivate_notifications: [0, nil]}).select("users.id as user_id,projects.id as project_id, projects.name").as_json

        user_ids = []

        shift_projects.map do |i|
             user_ids.push(i["user_id"]) 
        end
        user_ids = user_ids.uniq

        today_date = Time.now.utc.to_date
        token_information = TimeEntry.where(:user_id=> user_ids).where("DATE(date_of_activity)='#{today_date}'").joins(:user=> :user_devices).select("time_entries.id as entry_id, week_id, users.id as user_id, user_devices.user_token as user_token")
        token_info =  token_information.select{|hash| !hash[:user_token].blank?}.as_json    

        push_messages = []

        token_info.map do |ti|
            cur_user_id = ti["user_id"]
            token = ti["user_token"]
            entry_id = ti["entry_id"]
            week_id = ti["week_id"]

            projects = []
                    
            shift_projects.select{|i| i["user_id"] == cur_user_id}.map do |p|
                projects.push({id: p["project_id"], name: p["name"]})
            end
            projects =  projects.uniq

            projects.map do |p|
                push_messages.push({
                    to: token,
                    title:"#{starting_shift ? "Starting Shift": "Ending Shift"} - #{p[:name]}",
                    sound: "default",
                    data: {entryID: entry_id, weekID: week_id, projectID: p[:project_id], userID: cur_user_id},
                    body: "Are you ready to fill your time sheet for the day?"
                })
            end
        end
        UserDevice.handle_push_notifications(push_messages)
    end

    def self.handle_push_notifications(messages)  
        # MAX 100 messages at a time
        if !messages.nil? 
            max_messages = 100
            while messages.count>0 do
                messages_to_process = messages.first(max_messages)
                UserDevice.send_push_notification(messages_to_process)
                messages = messages.drop(max_messages)
            end
        end
    end

    def self.send_push_notification(messages)
        begin
            client = Exponent::Push::Client.new

            # MAX 100 messages at a time
            handler = client.send_messages(messages)

            # Array of all errors returned from the API
            # puts handler.errors

            # you probably want to delay calling this because the service might take a few moments to send
            # client.verify_deliveries(handler.receipt_ids)
        rescue            
        end        
    end
end
  