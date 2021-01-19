Ckeditor.setup do |config|
  require 'ckeditor/orm/active_record'
  config.image_file_types = %w(jpg jpeg png gif tiff)
  config.attachment_file_types = %w(doc docx xls odt ods pdf rar zip tar tar.gz swf)
  config.js_config_url = 'ckeditor/config.js'
  config.cdn_url = "//cdn.ckeditor.com/4.7.0/standard/ckeditor.js"
end
