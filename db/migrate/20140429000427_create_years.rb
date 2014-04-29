class CreateYears < ActiveRecord::Migration
  def change
    create_table :years do |t|
      t.references :student_program, index: true
      t.timestamps
    end
  end
end
