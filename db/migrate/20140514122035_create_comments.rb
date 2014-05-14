class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :content
      t.timestamps
      t.references :student_program
      t.boolean :read, default: false
    end
  end
end
