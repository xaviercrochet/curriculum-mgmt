class CreateSemesters < ActiveRecord::Migration
  def change
    create_table :semesters do |t|

      t.timestamps
    end
  end
end
