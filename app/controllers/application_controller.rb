class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include FormatConcern
  include SecretsConcern
  protect_from_forgery with: :exception


  include CanCan::ControllerAdditions
  
  before_action :authenticate_user!, :set_mailer_host, :set_access_token, :set_base_url, :find_faq
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to "/permission_denied", :alert => exception.message
  end

  protected

  def configure_permitted_parameters
    #Uncomment the below line if you are using devise version less than 4
    # devise_parameter_sanitizer.for(:accept_invitation).concat([:name])

    # The Parameter Sanitizer API has changed for Devise 4,please comment this line if you are using lower version of devise
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:name])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :project_id, :invited_by_id])
  end

  private

  def set_mailer_host
    # ActionMailer::Base.default_url_options[:host] = "http://192.168.239.178:3000/users/sign_up"
  end

  def find_faq
    if current_user.present? && current_user.cm?
      @faq = Feature.where(feature_type: "FAQ for Customer Manager").last
    elsif current_user.present? &&  current_user.pm?
      @faq = Feature.where(feature_type: "FAQ for Project Manager").last
    elsif current_user.present?
      @faq = Feature.where(feature_type: "FAQ for User").last
    end
  end

  def after_invite_path_for(resource)
    projects_path
  end

  def set_access_token
        @access_token = session[:token];
  end

  def set_base_url
    @base_url = get_base_url
  end

  def authenticate_user_token
    #CHECK IF TOKEN IS VALID DATEWISE, ROLEWISE, AND SET CURRENT USER
    token_info = User.decode_jwt_token(request.headers["Authorization"])
    cur_user = nil
    if token_info != nil # Token is valid
        valid_session = token_expired?(token_info)
        cur_user = {'user_id': token_info[:user_id],'valid_session': valid_session}
    end
  end

  def token_expired?(token_info)
    Time.now.to_i <= token_info[:exp]
  end


  def current_ability
    cur_user = current_user
    if(cur_user == nil)
      user = authenticate_user_token()
      if(user != nil)
        cur_user = User.find(user[:user_id])
        @current_user = cur_user
      end
    end

    if(cur_user == nil)
       cur_user = User.new
    end

     @current_ability ||= Ability.new(cur_user)
  end

  private 

end

