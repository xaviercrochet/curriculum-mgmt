class CreateValidations < ActiveRecord::Migration
  def change
    create_table :validations do |t|
      t.references :student_program, index: true
      t.timestamps
    end
  end
end
