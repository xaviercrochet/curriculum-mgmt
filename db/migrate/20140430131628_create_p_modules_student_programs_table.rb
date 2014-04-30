class CreatePModulesStudentProgramsTable < ActiveRecord::Migration
  def change
    create_table :p_modules_student_programs, id: false do |t|
      t.references :student_program, index: true
      t.references :p_module, index: true
    end
  end
end
