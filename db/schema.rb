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

ActiveRecord::Schema.define(version: 20140527080920) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "academic_years", force: true do |t|
    t.integer  "start_year"
    t.integer  "end_year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "answers", force: true do |t|
    t.integer  "justification_id"
    t.string   "content"
    t.integer  "user_id"
    t.boolean  "read",             default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "catalogs", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "main",                     default: false
    t.string   "graph_file_name"
    t.string   "graph_content_type"
    t.integer  "graph_file_size"
    t.datetime "graph_updated_at"
    t.string   "spreadsheet_file_name"
    t.string   "spreadsheet_content_type"
    t.integer  "spreadsheet_file_size"
    t.datetime "spreadsheet_updated_at"
    t.integer  "academic_year_id"
    t.string   "name"
    t.integer  "version",                  default: 0
  end

  add_index "catalogs", ["academic_year_id"], name: "index_catalogs_on_academic_year_id", using: :btree

  create_table "constraint_exceptions", force: true do |t|
    t.integer  "justification_id"
    t.string   "message"
    t.integer  "entity_id"
    t.string   "entity_type"
    t.boolean  "completed",        default: false
    t.string   "constraint_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "courses", force: true do |t|
    t.integer  "catalog_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "p_module_id"
  end

  add_index "courses", ["catalog_id"], name: "index_courses_on_catalog_id", using: :btree
  add_index "courses", ["p_module_id"], name: "index_courses_on_p_module_id", using: :btree

  create_table "courses_programs", id: false, force: true do |t|
    t.integer "program_id"
    t.integer "course_id"
  end

  add_index "courses_programs", ["course_id"], name: "index_courses_programs_on_course_id", using: :btree
  add_index "courses_programs", ["program_id"], name: "index_courses_programs_on_program_id", using: :btree

  create_table "courses_semesters", id: false, force: true do |t|
    t.integer "semester_id"
    t.integer "course_id"
  end

  add_index "courses_semesters", ["course_id"], name: "index_courses_semesters_on_course_id", using: :btree
  add_index "courses_semesters", ["semester_id"], name: "index_courses_semesters_on_semester_id", using: :btree

  create_table "first_semesters", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "justifications", force: true do |t|
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "student_program_id"
    t.boolean  "read",               default: false
  end

  create_table "p_modules", force: true do |t|
    t.integer  "catalog_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
  end

  add_index "p_modules", ["catalog_id"], name: "index_p_modules_on_catalog_id", using: :btree
  add_index "p_modules", ["parent_id"], name: "index_p_modules_on_parent_id", using: :btree

  create_table "p_modules_programs", id: false, force: true do |t|
    t.integer "program_id"
    t.integer "p_module_id"
  end

  add_index "p_modules_programs", ["p_module_id"], name: "index_p_modules_programs_on_p_module_id", using: :btree
  add_index "p_modules_programs", ["program_id"], name: "index_p_modules_programs_on_program_id", using: :btree

  create_table "p_modules_student_programs", id: false, force: true do |t|
    t.integer "student_program_id"
    t.integer "p_module_id"
  end

  add_index "p_modules_student_programs", ["p_module_id"], name: "index_p_modules_student_programs_on_p_module_id", using: :btree
  add_index "p_modules_student_programs", ["student_program_id"], name: "index_p_modules_student_programs_on_student_program_id", using: :btree

  create_table "programs", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "catalog_id"
  end

  create_table "properties", force: true do |t|
    t.string   "p_type"
    t.string   "value"
    t.integer  "entity_id"
    t.string   "entity_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "primary",     default: false
  end

  create_table "second_semesters", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "semesters", force: true do |t|
    t.integer  "year_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  add_index "semesters", ["year_id"], name: "index_semesters_on_year_id", using: :btree

  create_table "student_programs", force: true do |t|
    t.integer  "program_id"
    t.boolean  "validated",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "checked",    default: false
  end

  add_index "student_programs", ["program_id"], name: "index_student_programs_on_program_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                  default: false
    t.integer  "catalog_id"
  end

  add_index "users", ["catalog_id"], name: "index_users_on_catalog_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "validations", force: true do |t|
    t.integer  "student_program_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "validations", ["student_program_id"], name: "index_validations_on_student_program_id", using: :btree

  create_table "years", force: true do |t|
    t.integer  "student_program_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "academic_year_id"
    t.integer  "status",             default: 0
  end

  add_index "years", ["academic_year_id"], name: "index_years_on_academic_year_id", using: :btree
  add_index "years", ["student_program_id"], name: "index_years_on_student_program_id", using: :btree

end
