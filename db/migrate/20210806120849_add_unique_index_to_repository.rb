class AddUniqueIndexToRepository < ActiveRecord::Migration[6.0]
  def change
    add_index :repositories, [:workspace, :repository_name], unique: true
  end
end
