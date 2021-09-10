class Project < ApplicationRecord
  include AASM

  belongs_to :locale_file
  delegate :repository, to: :locale_file

  ATTRIBUTE_ENCODING_KEY = Rails.application.secrets.attribute_encoding_key

  extend AttrEncrypted
  attr_encrypted :access_token, key: ATTRIBUTE_ENCODING_KEY, encode: 'M'

  validates :status, :file_path, :algined_from, :language_to, :file_format,
            :access_token, presence: true

  enum status: {
    open: 0, processing: 10, finalized: 20, waiting: 30, failed: 40
  }

  aasm column: :status, enum: true, requires_lock: true do
    state :open, initial: true
    state :processing
    state :finalized
    state :waiting
    state :failed

    event :process do
      transitions from: :open, to: :processing
    end

    event :finalize do
      transitions from: :processing, to: :finalized
    end

    event :wait do
      transitions from: :open, to: :waiting
    end

    event :fail do
      transitions from: :processing, to: :failed
    end
  end

  # NOTE(waiting): This functionality is without effect at the moment
  # try_to_open! should verify that there is no open pull request
  def try_to_open!
    return if Project.exists?(file_path: file_path, locale_file_id: locale_file_id,
                              status: %i[open processing])

    open!
  end
end
