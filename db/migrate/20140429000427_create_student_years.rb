class CreateStudentYears < ActiveRecord::Migration
  def change
    create_table :student_years do |t|

      t.timestamps
    end
  end
end
