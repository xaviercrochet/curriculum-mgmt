class CreateCoursesSemestersTable < ActiveRecord::Migration
  def change
    create_table :courses_semesters, id: false do |t|
      t.references :semester, index: true
      t.references :course, index: true
    end
  end
end
