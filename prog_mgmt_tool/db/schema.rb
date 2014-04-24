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

ActiveRecord::Schema.define(version: 20140424095541) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "catalogs", force: true do |t|
    t.string   "faculty"
    t.string   "department"
    t.string   "ss_filename"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "filename"
  end

  create_table "constraint_set_types", force: true do |t|
    t.string   "name"
    t.integer  "catalog_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "constraint_set_types", ["catalog_id"], name: "index_constraint_set_types_on_catalog_id", using: :btree

  create_table "constraint_sets", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "constraint_set_type_id"
  end

  add_index "constraint_sets", ["constraint_set_type_id"], name: "index_constraint_sets_on_constraint_set_type_id", using: :btree

  create_table "constraint_types", force: true do |t|
    t.string   "name"
    t.integer  "catalog_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "constraint_types", ["catalog_id"], name: "index_constraint_types_on_catalog_id", using: :btree

  create_table "constraints", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "constraint_type_id"
    t.integer  "course_id"
    t.string   "set_type",           default: "binary"
  end

  add_index "constraints", ["constraint_type_id"], name: "index_constraints_on_constraint_type_id", using: :btree
  add_index "constraints", ["course_id"], name: "index_constraints_on_course_id", using: :btree

  create_table "constraints_courses", id: false, force: true do |t|
    t.integer "course_id"
    t.integer "constraint_id"
  end

  add_index "constraints_courses", ["constraint_id"], name: "index_constraints_courses_on_constraint_id", using: :btree
  add_index "constraints_courses", ["course_id"], name: "index_constraints_courses_on_course_id", using: :btree

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

  add_index "course_entities", ["course_id"], name: "index_course_entities_on_course_id", using: :btree
  add_index "course_entities", ["semester_id"], name: "index_course_entities_on_semester_id", using: :btree

  create_table "courses", force: true do |t|
    t.integer  "catalog_id"
    t.integer  "block_id"
    t.string   "block_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "courses", ["block_id", "block_type"], name: "index_courses_on_block_id_and_block_type", using: :btree
  add_index "courses", ["catalog_id"], name: "index_courses_on_catalog_id", using: :btree

  create_table "courses_user_catalogs", id: false, force: true do |t|
    t.integer "user_catalog_id"
    t.integer "course_id"
  end

  add_index "courses_user_catalogs", ["course_id"], name: "index_courses_user_catalogs_on_course_id", using: :btree
  add_index "courses_user_catalogs", ["user_catalog_id"], name: "index_courses_user_catalogs_on_user_catalog_id", using: :btree

  create_table "p_modules", force: true do |t|
    t.integer  "catalog_id"
    t.integer  "program_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "p_modules", ["catalog_id"], name: "index_p_modules_on_catalog_id", using: :btree
  add_index "p_modules", ["program_id"], name: "index_p_modules_on_program_id", using: :btree

  create_table "p_modules_user_catalogs", id: false, force: true do |t|
    t.integer "user_catalog_id"
    t.integer "p_module_id"
  end

  add_index "p_modules_user_catalogs", ["p_module_id"], name: "index_p_modules_user_catalogs_on_p_module_id", using: :btree
  add_index "p_modules_user_catalogs", ["user_catalog_id"], name: "index_p_modules_user_catalogs_on_user_catalog_id", using: :btree

  create_table "programs", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "catalog_id"
  end

  create_table "programs_user_catalogs", id: false, force: true do |t|
    t.integer "user_catalog_id"
    t.integer "program_id"
  end

  add_index "programs_user_catalogs", ["program_id"], name: "index_programs_user_catalogs_on_program_id", using: :btree
  add_index "programs_user_catalogs", ["user_catalog_id"], name: "index_programs_user_catalogs_on_user_catalog_id", using: :btree

  create_table "properties", force: true do |t|
    t.string   "p_type"
    t.string   "value"
    t.integer  "entity_id"
    t.string   "entity_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "primary",     default: false
  end

  create_table "sub_modules", force: true do |t|
    t.integer  "p_module_id"
    t.integer  "catalog_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sub_modules", ["catalog_id"], name: "index_sub_modules_on_catalog_id", using: :btree
  add_index "sub_modules", ["p_module_id"], name: "index_sub_modules_on_p_module_id", using: :btree

  create_table "sub_modules_user_catalogs", id: false, force: true do |t|
    t.integer "user_catalog_id"
    t.integer "sub_module_id"
  end

  add_index "sub_modules_user_catalogs", ["sub_module_id"], name: "index_sub_modules_user_catalogs_on_sub_module_id", using: :btree
  add_index "sub_modules_user_catalogs", ["user_catalog_id"], name: "index_sub_modules_user_catalogs_on_user_catalog_id", using: :btree

  create_table "user_catalogs", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_catalogs", ["user_id"], name: "index_user_catalogs_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
