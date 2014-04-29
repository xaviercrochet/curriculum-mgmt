class CreateStudentPrograms < ActiveRecord::Migration
  def change
    create_table :student_programs do |t|
      t.references :program, index: true
      t.timestamps
    end
  end
end
