Apipie.configure do |config|
  config.app_name                = "TimeStack"
  config.copyright               = "&copy; 2020 Resource Stack Inc"
  config.doc_base_url            = "/docs"
  config.validate                = false
  config.translate               = false
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
end
