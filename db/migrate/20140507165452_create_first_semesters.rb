class CreateFirstSemesters < ActiveRecord::Migration
  def change
    create_table :first_semesters do |t|

      t.timestamps
    end
  end
end
