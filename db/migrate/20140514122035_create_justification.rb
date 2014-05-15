class CreateJustifications < ActiveRecord::Migration
  def change
    create_table :justifications do |t|
      t.string :content
      t.timestamps
      t.references :student_program
      t.boolean :read, default: false
    end
  end
end
