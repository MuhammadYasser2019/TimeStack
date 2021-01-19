class ArchivedTimeEntriesController < ApplicationController
  before_action :set_archived_time_entry, only: [:show, :edit, :update, :destroy]

  # GET /archived_time_entries
  # GET /archived_time_entries.json
  def index
    if current_user.pm = 1 || current_user.cm = 1
    @archived_time_entries = ArchivedTimeEntry.all
    else
      redirect_to root_path
    end 
  end

  # GET /archived_time_entries/1
  # GET /archived_time_entries/1.json
  def show
    @archived_time_entries = ArchivedTimeEntry.find(params[:id])
    @archived_weeks = ArchivedWeek.all
    @statuses = Status.find(@archived_time_entries.status_id)
    @projects =  Project.all
    @task = Task.find(@archived_time_entries.task_id)
   
  end

  # GET /archived_time_entries/new
  def new
    @archived_time_entry = ArchivedTimeEntry.new
  end

  # GET /archived_time_entries/1/edit
  def edit
  end

  # POST /archived_time_entries
  # POST /archived_time_entries.json
  def create
    @archived_time_entry = ArchivedTimeEntry.new(archived_time_entry_params)

    respond_to do |format|
      if @archived_time_entry.save
        format.html { redirect_to @archived_time_entry, notice: 'Archived time entry was successfully created.' }
        format.json { render :show, status: :created, location: @archived_time_entry }
      else
        format.html { render :new }
        format.json { render json: @archived_time_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /archived_time_entries/1
  # PATCH/PUT /archived_time_entries/1.json
  def update
    respond_to do |format|
      if @archived_time_entry.update(archived_time_entry_params)
        format.html { redirect_to @archived_time_entry, notice: 'Archived time entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @archived_time_entry }
      else
        format.html { render :edit }
        format.json { render json: @archived_time_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /archived_time_entries/1
  # DELETE /archived_time_entries/1.json
  def destroy
    @archived_time_entry.destroy
    respond_to do |format|
      format.html { redirect_to archived_time_entries_url, notice: 'Archived time entry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_archived_time_entry
      @archived_time_entry = ArchivedTimeEntry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def archived_time_entry_params
      params.fetch(:archived_time_entry, {})
    end
end
