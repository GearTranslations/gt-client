class CreateRepositories < ActiveRecord::Migration[6.0]
  def change
    create_table :repositories do |t|
      t.string :type, null: false
      t.string :workspace
      t.string :repository_name
      t.string :branch
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end
  end
end
