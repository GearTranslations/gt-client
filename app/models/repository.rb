class Repository < ApplicationRecord
  validates :workspace, :repository_name, :branch, :metadata, presence: true
  validates :workspace, uniqueness: { scope: :repository_name }

  def scan
    raise 'Implement on derived classes'
  end
end
