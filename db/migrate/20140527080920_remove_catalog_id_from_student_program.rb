class RemoveCatalogIdFromStudentProgram < ActiveRecord::Migration
  def change
    remove_column :student_programs, :catalog_id
    remove_column :student_programs, :errors_count 
  end
end
