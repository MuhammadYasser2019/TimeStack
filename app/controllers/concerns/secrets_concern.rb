module SecretsConcern
    include ActiveSupport::Concern
        
    def get_base_url
        Rails.application.secrets[:base_access_url]
    end
end