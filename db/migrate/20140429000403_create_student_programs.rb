class CreateStudentPrograms < ActiveRecord::Migration
  def change
    create_table :student_programs do |t|
      t.references :program, index: true
      t.boolean :validated, default: false
      t.timestamps
    end
  end
end
