# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170705103344) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "interactions", force: :cascade do |t|
    t.text "username"
    t.bigint "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_interactions_on_post_id"
  end

  create_table "links", force: :cascade do |t|
    t.bigint "post_id"
    t.integer "outgoing_post_id"
    t.text "abbreviation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["abbreviation"], name: "index_links_on_abbreviation"
    t.index ["outgoing_post_id"], name: "index_links_on_outgoing_post_id"
    t.index ["post_id"], name: "index_links_on_post_id"
  end

  create_table "posts", force: :cascade do |t|
    t.text "title"
    t.text "description"
    t.text "url"
    t.boolean "start"
    t.boolean "end"
    t.integer "importance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
