class CreateSemesters < ActiveRecord::Migration
  def change
    create_table :semesters do |t|
      t.references :year, index: true
      t.integer :slot
      t.timestamps
    end
  end
end
