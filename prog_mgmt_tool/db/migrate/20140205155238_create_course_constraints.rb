class CreateCourseConstraints < ActiveRecord::Migration
  def change
    create_table :course_constraints do |t|
      t.string :constraint_type
      t.references :program, index: true
      t.references :first_course, index: true
      t.string :first_course_sigle
      t.references :second_course, index: true
      t.string :second_course_sigle
      t.timestamps
    end
  end
end
