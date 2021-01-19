class ReportLogosController < ApplicationController

	def index
	end

	def show
	end

	def new
		@report_logo = ReportLogo.new
	end

	def edit
	end

	def create
		logger.debug("REPORTS LOGO PARAMS ARE: #{params.inspect}")
		report_logo = ReportLogo.new

		report_logo.name = params[:name]
		report_logo.report_logo = params[:report_logo]
		report_logo.save

		respond_to do |format|
		if report_logo.save
			format.html { redirect_to '/admin', notice: 'Report Logo was successfully created.' }
		else
			format.html {render root}
		end
		end		
	end

	def update
	end

	def check_report_logo
		@all_report_logos = ReportLogo.all
	end



	private

	def report_logo_params
		params.require(:report_logo).permit(:name, :report_logo)
	end

end
