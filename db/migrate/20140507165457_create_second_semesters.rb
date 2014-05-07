class CreateSecondSemesters < ActiveRecord::Migration
  def change
    create_table :second_semesters do |t|

      t.timestamps
    end
  end
end
