class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name
      t.string :sigle
      t.references :catalog, index: true
      t.references :block, polymorphic: true, index: true
      t.timestamps
    end
  end
end
