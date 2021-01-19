class UploadTimesheet < ApplicationRecord
  mount_uploader :time_sheet, TimeSheetUploader
  belongs_to :week
end