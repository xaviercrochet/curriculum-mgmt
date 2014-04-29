class CreateStudentPrograms < ActiveRecord::Migration
  def change
    create_table :student_programs do |t|

      t.timestamps
    end
  end
end
