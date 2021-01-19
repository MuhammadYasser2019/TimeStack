class HolidayExceptionsController < ApplicationController
  before_action :set_holiday_exception, only: [:show, :edit, :update, :destroy]

  # GET /holiday_exceptions
  # GET /holiday_exceptions.json
  def index
    @holiday_exceptions = HolidayException.all
  end

  # GET /holiday_exceptions/1
  # GET /holiday_exceptions/1.json
  def show
  end

  # GET /holiday_exceptions/new
  def new
    @holiday_exception = HolidayException.new
  end

  # GET /holiday_exceptions/1/edit
  def edit
    @holiday_exceptions = HolidayException.all
    customer_holiday_ids = CustomersHoliday.where(customer_id: @holiday_exception.customer_id).pluck(:holiday_id)
    @holidays = Holiday.where(global:true).or(Holiday.where(id: customer_holiday_ids))
  end

  # POST /holiday_exceptions
  # POST /holiday_exceptions.json
  def create
    @holiday_exception = HolidayException.new(holiday_exception_params)
    @project = Project.find holiday_exception_params[:project_id]
    @customer = Customer.find(@project.customer_id)
        
    @users_on_project = User.joins("LEFT OUTER JOIN projects_users ON users.id = projects_users.user_id AND projects_users.project_id = #{@project.id}").select("users.email,first_name,email,users.id id,user_id, projects_users.project_id, projects_users.active,project_id")
    respond_to do |format|
      if @holiday_exception.save
	@holiday_exceptions = @project.holiday_exceptions
	customer_holiday_ids = CustomersHoliday.where(customer_id: @holiday_exception.customer_id).pluck(:holiday_id)
    	@holidays = Holiday.where(global:true).or(Holiday.where(id: customer_holiday_ids))
	@holiday_exception = HolidayException.new
	format.js
        #format.html { redirect_to @holiday_exception, notice: 'Holiday exception was successfully created.' }
        format.json { render :show, status: :created, location: @holiday_exception }
      else
        format.html { render :new }
        format.json { render json: @holiday_exception.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /holiday_exceptions/1
  # PATCH/PUT /holiday_exceptions/1.json
  def update
    respond_to do |format|
      begin
      status = @holiday_exception.update(holiday_exception_params)
      rescue => e
        status = false
        customer_holiday_ids = CustomersHoliday.where(customer_id: @holiday_exception.customer_id).pluck(:holiday_id)
        @holidays = Holiday.where(global:true).or(Holiday.where(id: customer_holiday_ids))
        logger.debug"UPDATE #{e.inspect} , STATUS #{status}" 
      end
      if status
        format.html { redirect_to edit_holiday_exception_path(@holiday_exception), notice: 'Holiday exception was successfully updated.' }
        format.json { render :show, status: :ok, location: @holiday_exception }
      else
        format.html { render :edit }
        format.json { render json: @holiday_exception.errors, status: :unprocessable_entity }
      end

    end
  end

  # DELETE /holiday_exceptions/1
  # DELETE /holiday_exceptions/1.json
  def destroy
    @holiday_exception.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Holiday exception was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_holiday_exception
      @holiday_exception = HolidayException.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def holiday_exception_params
      params.require(:holiday_exception).permit(:user_id, :project_id, :customer_id, :holiday_ids => [])
    end
end
