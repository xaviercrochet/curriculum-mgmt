class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name
      t.string :sigle
      t.integer :credits
      t.string :url
      t.references :pmodule, index: true

      t.timestamps
    end
  end
end
