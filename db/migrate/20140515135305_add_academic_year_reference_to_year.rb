class AddAcademicYearReferenceToYear < ActiveRecord::Migration
  def change
    add_column :years, :academic_year_id, :integer
    add_index :years, :academic_year_id
    add_column :years, :status, :integer, default: 0
  end
end
