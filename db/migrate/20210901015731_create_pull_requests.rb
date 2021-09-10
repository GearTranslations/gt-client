class CreatePullRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :pull_requests do |t|
      t.integer :status, default: 0, null: false
      t.string :external_id
      t.references :locale_file, index: true, foreign_key: true, null: false
      t.references :project, index: true, foreign_key: true, null: false

      t.timestamps
    end
  end
end
