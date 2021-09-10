class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.integer :status, default: 0, null: false
      t.string :external_id
      t.string :file_path, null: false
      t.string :algined_from, null: false
      t.string :language_to, null: false
      t.string :file_format, null: false
      t.string :tag
      t.references :repository, index: true, foreign_key: true, null: false

      t.timestamps
    end
  end
end
