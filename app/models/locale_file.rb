class LocaleFile < ApplicationRecord
  belongs_to :repository
  has_many :projects, dependent: :destroy
  has_many :pull_requests, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :repository_id }
end
