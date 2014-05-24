class AddCheckedToStudentProgram < ActiveRecord::Migration
  def change
    add_column :student_programs, :checked, :boolean, default: false
  end
end
