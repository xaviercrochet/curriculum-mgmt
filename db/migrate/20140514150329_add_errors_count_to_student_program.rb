class AddErrorsCountToStudentProgram < ActiveRecord::Migration
  def change
    add_column :student_programs, :errors_count, :integer, default: -1
  end
end
