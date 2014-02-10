class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name
      t.string :sigle
      t.references :pmodule, index: true
      t.references :program, index: true
      t.timestamps
    end
  end
end
