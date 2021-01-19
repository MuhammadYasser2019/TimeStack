class ApplicationVersionsController < ApplicationController
    def get_items
        search_term = params[:search][:value]
        skip = params[:start]
        take = params[:length]
        draw = params[:draw]

        @total_data = ApplicationVersion
        if !search_term.empty?
            @total_data = @total_data.where('version_name LIKE ?',  "%#{search_term}%")
        end
        @total_data = @total_data.order(:id)

        total_items = @total_data.count
        @filtered_data =@total_data.offset(skip).limit(take).select(:id, :version_name, :description, :platform,:start_date).as_json

        render json: {
            draw: draw,
            recordsTotal: total_items,
            recordsFiltered: total_items,
            data: @filtered_data
        }
    end

    def delete_item
        begin
            version_id = params[:id]
            ApplicationVersion.find(version_id).destroy

            render json: format_response_json(
            {
                status: true				
            })
        rescue => exception
            render json: format_response_json(
            {
                status: false,
                message: "Failed to delete version!"
            })
        end
    end

    def edit_item
        begin
            @version = params[:version]
            version_id = @version[:id].to_i
            version_exists = ApplicationVersion.where(:version_name=> @version[:version_name], :platform=> @version[:platform]).where.not(:id=> version_id).count>0

            if version_exists
                render json: format_response_json({
                    status: false,
                    message: "Version already exists!"
                })
            else
                if version_id > 0
                    ApplicationVersion.find(version_id).update_attributes(application_versions_params(@version))
                else
                    @version = ApplicationVersion.new(application_versions_params(params[:version]))
                    @version.save
                end

                render json: format_response_json({
                    status: true,
                    result: @version
                })
            end
        rescue => exception
            render json: format_response_json({
                message: 'Failed to process the version!',
                status: false
            })
        end
    end

    def acknowledge_version
        @user_application_version = UsersApplicationVersion.where(:user_id=> current_user.id).joins(:application_version).where(:application_versions=>{platform:'web'}).first

        if @user_application_version.nil?
           @user_application_version =  UsersApplicationVersion.new
           @user_application_version.user_id = current_user.id
           @user_application_version.application_version_id = params[:id]
           @user_application_version.save
        else
            @user_application_version.application_version_id = params[:id]
            @user_application_version.save
        end

        render json: format_response_json(
        {
            status: true
        })
    end

    private 
    def application_versions_params(version)
        version.permit([:version_name, :start_date, :description, :platform])
    end
end