class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!
  def home

  end

  def about
    @about = Feature.find(9)
  end

  def features
    @feature_2 = Feature.find(2)
    @feature_3 = Feature.find(3)
    @feature_4 = Feature.find(4)
  end

  def privacy

  end

  def terms_of_service

  end

  def contact_form_mail
    respond_to do |format|
      if FeedbackMailer.contact_form_email(params[:email], params[:name], params[:message]).deliver
        format.html { flash[:notice] = "Email Sent!" }
        format.js { redirect_to root_path }
      else
        format.html { flash[:notice] = "Something Went Wrong, Our Developers Have Been Notified." }
        format.js { redirect_to root_path }
      end
    end
  end

end 

