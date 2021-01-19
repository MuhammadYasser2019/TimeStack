class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = Task.all
      
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @projects = Project.all
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
    @projects = Project.all
    
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: 'Task was successfully created.' }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def available_tasks
    logger.debug "available_tasks - starting to process, params passed  are #{params[:id]}"
    project_id  = params[:id]
    
    #@tasks = Task.where(project_id: project_id)
    @tasks = Task.where(["project_id =? AND active=?", project_id, true])
    logger.debug "available_tasks - leaving  @tasks is #{@tasks}"
    
  end

  def default_comment
    logger.debug "DEFAULT COMMENT - TASK CONTROLLER, params passed  are #{params[:id]}"
    task_id = params[:id]
    @row_id = params[:row_id]

    @comment = Task.find(task_id).default_comment

    logger.debug "default_comment - comment is #{@comment}"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:code, :description, :project_id, :default_comment,:estimated_time, :overtime, :active, :imported_from)
    end
end
