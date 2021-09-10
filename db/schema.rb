# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_09_01_015731) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "locale_files", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "last_update_date"
    t.bigint "repository_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "last_commit_message"
    t.index ["name", "repository_id"], name: "index_locale_files_on_name_and_repository_id", unique: true
    t.index ["repository_id"], name: "index_locale_files_on_repository_id"
  end

  create_table "projects", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "external_id"
    t.string "file_path", null: false
    t.string "algined_from", null: false
    t.string "language_to", null: false
    t.string "file_format", null: false
    t.string "tag"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "encrypted_access_token", null: false
    t.string "encrypted_access_token_iv", null: false
    t.bigint "locale_file_id"
    t.index ["locale_file_id"], name: "index_projects_on_locale_file_id"
  end

  create_table "pull_requests", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "external_id"
    t.bigint "locale_file_id", null: false
    t.bigint "project_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["locale_file_id"], name: "index_pull_requests_on_locale_file_id"
    t.index ["project_id"], name: "index_pull_requests_on_project_id"
  end

  create_table "repositories", force: :cascade do |t|
    t.string "type", null: false
    t.string "workspace"
    t.string "repository_name"
    t.string "branch"
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "branch_count", default: 0
    t.index ["workspace", "repository_name"], name: "index_repositories_on_workspace_and_repository_name", unique: true
  end

  add_foreign_key "locale_files", "repositories"
  add_foreign_key "projects", "locale_files"
  add_foreign_key "pull_requests", "locale_files"
  add_foreign_key "pull_requests", "projects"
end
