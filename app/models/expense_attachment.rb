class ExpenseAttachment < ApplicationRecord
	mount_uploader :attachment, AttachmentUploader
	belongs_to :expense_attachment
end
