class FeaturesController < ApplicationController

  skip_before_action :authenticate_user!
   
  def show
  	@feature = Feature.find params[:id]
  end
  
  def update_front_page_content
    @feature = Feature.find params[:feature_id]
    @feature.feature_data = params[:feature_content][:content]
    @feature.save
    respond_to do |format|
      format.js
    end
  end

  def available_data
    logger.debug "available_data - starting to process, params passed  are #{params[:id]}"
    feature_id  = params[:id]
    
    @feature = Feature.where(id: feature_id)
    logger.debug "available_feature - leaving  @feature is #{@feature}"

  end
end