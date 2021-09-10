class PullRequest < ApplicationRecord
  include AASM

  belongs_to :locale_file
  belongs_to :project

  validates :status, :locale_file, :project, :external_id, presence: true

  enum status: {
    open: 0, merged: 10, declined: 20
  }

  aasm column: :status, enum: true, requires_lock: true do
    state :open, initial: true
    state :merged
    state :declined

    event :merge do
      transitions from: :open, to: :merged
    end

    event :decline do
      transitions from: :open, to: :declined
    end
  end
end
