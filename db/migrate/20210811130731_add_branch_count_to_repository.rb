class AddBranchCountToRepository < ActiveRecord::Migration[6.0]
  def change
    add_column :repositories, :branch_count, :integer, default: 0
  end
end
