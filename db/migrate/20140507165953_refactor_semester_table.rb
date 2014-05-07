class RefactorSemesterTable < ActiveRecord::Migration
  def change
    remove_column :semesters, :slot, :string
    add_column :semesters, :type, :string
    remove_column :first_semesters, :slot, :string
    remove_column :second_semesters, :slot, :string
  end
end
