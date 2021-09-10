class AddLastCommitMessageToLocaleFiles < ActiveRecord::Migration[6.0]
  def change
    add_column :locale_files, :last_commit_message, :string
  end
end
