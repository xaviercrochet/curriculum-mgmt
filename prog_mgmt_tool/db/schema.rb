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

ActiveRecord::Schema.define(version: 20140218170021) do

  create_table "catalogs", force: true do |t|
    t.string   "faculty"
    t.string   "department"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "filename"
  end

  create_table "course_constraints", force: true do |t|
    t.string   "constraint_type"
    t.integer  "course_id"
    t.integer  "second_course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_constraints", ["course_id"], name: "index_course_constraints_on_course_id"
  add_index "course_constraints", ["second_course_id"], name: "index_course_constraints_on_second_course_id"

  create_table "course_entities", force: true do |t|
    t.string   "year"
    t.integer  "credits"
    t.string   "professor"
    t.string   "url"
    t.integer  "course_id"
    t.integer  "semester_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "course_entities", ["course_id"], name: "index_course_entities_on_course_id"
  add_index "course_entities", ["semester_id"], name: "index_course_entities_on_semester_id"

  create_table "courses", force: true do |t|
    t.string   "name"
    t.string   "sigle"
    t.integer  "block_id"
    t.string   "block_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "courses", ["block_id", "block_type"], name: "index_courses_on_block_id_and_block_type"

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
    t.integer  "catalog_id"
  end

  create_table "semesters", force: true do |t|
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sub_modules", force: true do |t|
    t.string   "name"
    t.integer  "p_module_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sub_modules", ["p_module_id"], name: "index_sub_modules_on_p_module_id"

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "user_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
