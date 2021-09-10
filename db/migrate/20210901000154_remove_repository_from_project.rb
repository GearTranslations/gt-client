class RemoveRepositoryFromProject < ActiveRecord::Migration[6.0]
  def change
    remove_reference :projects, :repository, index: true, foreign_key: true
  end
end
