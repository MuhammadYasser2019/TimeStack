module Api
    class NotificationsController < BaseController
        api :POST, '/save_device_info', "Save / Update current device information"
        formats ['json']
        param :userID, Integer, :desc => "User ID of the current user", :required => true
        param :deviceID, String, :desc => "Unique device identifier", :required => true
        param :userToken, String, :desc => "Notification token for the user device", :required => true
        param :platform, String, :desc => "Device platform (IOS/Android)", :required => true
	
        def save_device_info
            begin
                UserDevice.save_device_information(params[:userID], params[:deviceID], nil,nil, params[:userToken]);
    
                render json: format_response_json({
                    status: true
                })
            rescue => exception
                render json: format_response_json({
					message: 'Failed to save push token!',
					status: false
				})
            end
        end

        api :GET, '/remove_device_info', "Remove the notification token for the user"
		formats ['json']
        param :userID, Integer, :desc => "User ID of the current user", :required => true
        param :deviceID, String, :desc => "Unique device identifier", :required => true
        def remove_device_info
           begin
                @user_id = params[:userID]
                @device_id = params[:deviceID]
                
                @user_device = UserDevice.where(:device_id => @device_id, :user_id => @user_id).first
                
                if @user_device.nil?
                    @user_device.user_token = nil
                    @user_device.save
                end

                render json: format_response_json({
                    message: 'Successfully removed push token!',
                    status: true
                })
           rescue => exception
                render json: format_response_json({
                    message: 'Failed to remove push token!',
                    status: false
                })
           end
        end
    end
end