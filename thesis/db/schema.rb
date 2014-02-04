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

ActiveRecord::Schema.define(version: 20140204143610) do

  create_table "courses", force: true do |t|
    t.string   "name"
    t.string   "sigle"
    t.integer  "credits"
    t.string   "url"
    t.integer  "pmodule_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "courses", ["pmodule_id"], name: "index_courses_on_pmodule_id"

  create_table "p_modules", force: true do |t|
    t.string   "name"
    t.string   "module_type"
    t.integer  "credits"
    t.integer  "program_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "p_modules", ["program_id"], name: "index_p_modules_on_program_id"

  create_table "programs", force: true do |t|
    t.string   "cycle"
    t.string   "program_type"
    t.integer  "credits"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
