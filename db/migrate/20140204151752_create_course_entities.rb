class CreateCourseEntities < ActiveRecord::Migration
  def change
    create_table :course_entities do |t|
      t.date :date
      t.integer :credits
      t.string :professor
      t.string :url
      t.references :course, index: true
      t.references :semester, index: true

      t.timestamps
    end
  end
end
