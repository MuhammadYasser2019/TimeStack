class RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: [:create]

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
       prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

       resource_updated = update_resource(resource, account_update_params)
       yield resource if block_given?
       if resource_updated
         #set_flash_message_for_update(resource, prev_unconfirmed_email)
         bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?

         redirect_to user_profile_path
       else
         clean_up_passwords resource
         set_minimum_password_length
         respond_with resource
      end
  end

  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password,:image,:emergency_contact)
  end

  def check_captcha
    unless verify_recaptcha
      self.resource = resource_class.new sign_up_params
      respond_with_navigational(resource) { render :new }
    end
  end


def set_flash_message_for_update(resource, prev_unconfirmed_email)
  super

end

def sign_in_after_change_password?
    return true if account_update_params[:password].blank?

    Devise.sign_in_after_change_password
  end

 

end