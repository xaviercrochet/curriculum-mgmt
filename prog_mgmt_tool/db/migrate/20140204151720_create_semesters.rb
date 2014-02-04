class CreateSemesters < ActiveRecord::Migration
  def change
    create_table :semesters do |t|
      t.date :date

      t.timestamps
    end
  end
end
