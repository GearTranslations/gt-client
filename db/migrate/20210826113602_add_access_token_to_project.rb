class AddAccessTokenToProject < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :encrypted_access_token, :string, null: false
    add_column :projects, :encrypted_access_token_iv, :string, null: false
  end
end
