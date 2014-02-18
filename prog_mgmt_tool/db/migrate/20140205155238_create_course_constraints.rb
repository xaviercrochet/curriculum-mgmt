class CreateCourseConstraints < ActiveRecord::Migration
  def change
    create_table :course_constraints do |t|
      t.string :constraint_type
      #t.references :program, index: true
      t.references :course, index: true
      t.references :second_course, index: true
      t.timestamps
    end
  end
end
