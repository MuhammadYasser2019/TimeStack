class CaseStudiesController < ApplicationController
  skip_before_action :authenticate_user!
  def show
  	@case_study = CaseStudy.find params[:id]
  end
end