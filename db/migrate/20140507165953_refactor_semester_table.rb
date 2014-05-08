class RefactorSemesterTable < ActiveRecord::Migration
  def change
    remove_column :semesters, :slot, :string
    add_column :semesters, :type, :string
  end
end
