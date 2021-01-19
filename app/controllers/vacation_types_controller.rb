class VacationTypesController < ApplicationController
  
  def index
    @customer_id = params[:customer_id]
    @vacation_types = VacationType.where(customer_id: @customer_id)
  end
  
  def new
    logger.debug("VT- new- ***********")
    @vacation_type = VacationType.new
    @customer_id = params[:customer_id]
  end

  def create
    @vacation_type = VacationType.new(vacation_type_params)
    logger.debug("VT- create- ***********current_user.customer_id #{current_user.customer_id}")

    if @vacation_type.save
      redirect_to vacation_types_path(customer_id: @vacation_type.customer_id)
    else
      redirect_to vacation_types_path(customer_id: vacation_type_params[:customer_id])
    end
  end

  def edit
    logger.debug("VT- edit- ***********")
    @vacation_type = VacationType.find(params[:id])
    @customer_id = @vacation_type.customer_id

  end

  def update
    vacation_type = VacationType.find(params[:id])
    logger.debug("VT- update- *********** #{vacation_type.inspect}")
    if vacation_type.update(vacation_type_params)
      redirect_to vacation_types_path(customer_id: vacation_type.customer_id)
    else
      redirect_to "vacation_types/#{params[:id]}/edit"
    end
  end

  def destroy
    vacation_type = VacationType.find(params[:id])
    @customer = Customer.find(vacation_type.customer_id)
    @vacation_type = VacationType.where(customer_id: vacation_type.customer_id)
    if vacation_type.destroy
      respond_to do |format|
	format.js
      end
    end
  end

  private 

  def vacation_type_params
    params.require(:vacation_type).permit(:vacation_title, :customer_id, :active, :vacation_bank, :paid, :accrual, :rollover)
  end
end
