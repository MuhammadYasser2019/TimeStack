 module Api
    class BaseController < ActionController::Base
        include FormatConcern
        include UserHelper
        before_action :authenticate_user

        private 

        def authenticate_user
           @user = authenticate_user_from_token()
        end
    end
end