# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20171113055854) do

  create_table "amount_regexes", force: :cascade do |t|
    t.integer "organization_id"
    t.string  "regex"
  end

  add_index "amount_regexes", ["organization_id"], name: "index_amount_regexes_on_organization_id"

  create_table "donations", force: :cascade do |t|
    t.float    "amount"
    t.date     "donation_date"
    t.boolean  "recurring"
    t.boolean  "matching"
    t.integer  "User_id"
    t.integer  "Organization_id"
    t.integer  "Processor_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "organization_string"
    t.boolean  "deductible"
  end

  add_index "donations", ["Organization_id"], name: "index_donations_on_Organization_id"
  add_index "donations", ["Processor_id"], name: "index_donations_on_Processor_id"
  add_index "donations", ["User_id"], name: "index_donations_on_User_id"

  create_table "org_regexes", force: :cascade do |t|
    t.integer "organization_id"
    t.string  "regex"
  end

  add_index "org_regexes", ["organization_id"], name: "index_org_regexes_on_organization_id"

  create_table "organizations", force: :cascade do |t|
    t.integer  "ein"
    t.string   "name"
    t.string   "alias",                 default: "ActiveRecord::Schema"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.integer  "subsection"
    t.integer  "classification"
    t.datetime "ruling_date"
    t.integer  "exemption_code"
    t.string   "homepage"
    t.integer  "foundation_code"
    t.string   "donation_page_url"
    t.string   "image"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.string   "country"
    t.string   "domain_name"
    t.string   "blah"
    t.string   "type"
    t.string   "check_donation_string"
    t.string   "org_regex"
  end

  add_index "organizations", ["alias"], name: "index_organizations_on_alias"

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "income"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "password_reset_token"
    t.boolean  "admin"
  end

  add_index "users", ["password_reset_token"], name: "index_users_on_password_reset_token"

end
