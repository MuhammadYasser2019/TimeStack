class EmploymentTypesController < ApplicationController
  def new
    logger.debug("ET- new- ***********")
    @employment_type = EmploymentType.new
    @customer_id = params[:customer_id]
  end

  def create
    @employment_type = EmploymentType.new(employment_type_params)
    logger.debug("ET- create- ***********current_user.customer_id #{current_user.customer_id}")
    # customer_id = current_user.customer_id
    # @employment_type.customer_id = customer_id
    if @employment_type.save
      redirect_to customers_path
    else
      redirect_to customers_path
    end
  end

  def edit
    logger.debug("ET- edit- ***********")
    @employment_type = EmploymentType.find(params[:id])
     @customer_id = @employment_type.customer_id

  end

  def update
    
    employment_type = EmploymentType.find(params[:id])
    logger.debug("ET- update- *********** #{employment_type.inspect}")
    if employment_type.update(employment_type_params)
      redirect_to "/customers/#{employment_type.customer_id}/edit"
    else
      redirect_to "employment_types/#{params[:id]}/edit"
    end
  end

  def destroy
    employment_type = EmploymentType.find(params[:id])
    @customer = Customer.find(employment_type.customer_id)
    @employment_type = EmploymentType.where(customer_id: employment_type.customer_id)
    if employment_type.destroy
      respond_to do |format|
	format.js
      end
    end
  end

  private

  def employment_type_params
    params.require(:employment_type).permit(:name, :customer_id)
  end
end
