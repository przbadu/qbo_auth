class Activity < ApplicationRecord
  # enum
  enum action: { bulk_archive: 0, import: 1, export: 2 }
  # associations
  belongs_to :user
  belongs_to :qbo_account
end
