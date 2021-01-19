class AnnouncementsController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :set_announcement, only: [:edit, :update_announcement, :destroy]

  def index
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def create
    if params[:announcement_id].present?
      @announcement = Announcement.find_by_id params[:announcement_id]
    else
      @announcement = Announcement.new
    end
    @announcement.announcement_type = params[:announcement_type]
    @announcement.announcement_text = params[:text_content]   
    @announcement.active =params[:active]    
    @announcement.seen = false
    @announcement.save
    redirect_to  "/admin#announcementPanel"
    # respond_to do |format|
    #   format.js
    # end
  end

   def destroy    
    @announcement.destroy
    redirect_to admin_path
  end

  def update_announcement
    @user_announcement = UserAnnouncement.where(user_id: current_user.id, announcement_id: @announcement.id).last
    unless @user_announcement.present?
      UserAnnouncement.create!(user_id: current_user.id, announcement_id: @announcement.id)
    end
  end


  private
  
  def set_announcement
    @announcement = Announcement.find_by_id(params[:id])
  end
  
end