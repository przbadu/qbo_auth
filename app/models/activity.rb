class Activity < ApplicationRecord
  # enum
  enum action: { bulk_archive: 0, import: 1, export: 2 }

  # associations
  belongs_to :user
  belongs_to :qbo_account

  ### scopes
  scope :user_with_job_id, -> (user, job_id)  { where(user: user, job_id: job_id)}
end
