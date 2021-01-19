class UsersApplicationVersion < ApplicationRecord
    belongs_to :application_version

    def self.validate_user_application_version(user_id)
        user_application_version = UsersApplicationVersion.where(:user_id=>user_id).joins(:application_version).where(:application_versions=>{platform:'web'}).select("application_versions.id as version_id, application_versions.version_name as version_name, application_versions.description as description").first

        latest_version_id = ApplicationVersion.where(:platform=>"web").order('id desc').limit(1).pluck(:id)[0]
  
        latest_version = nil
        if (user_application_version.nil? || latest_version_id != user_application_version[:version_id] ) && !latest_version_id.nil?
         latest_version = ApplicationVersion.find(latest_version_id)
        end
        application_version = {
            user_application_version: user_application_version.as_json,
            latest_version: latest_version
        }
    end
end