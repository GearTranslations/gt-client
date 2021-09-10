class CreateLocaleFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :locale_files do |t|
      t.string :name, null: false
      t.datetime :last_update_date
      t.references :repository, index: true, foreign_key: true, null: false

      t.timestamps
    end

    add_index :locale_files, [:name, :repository_id], unique: true
  end
end
