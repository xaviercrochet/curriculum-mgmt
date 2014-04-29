class AddCatalogIdToStudentPrograms < ActiveRecord::Migration
  def change
    add_column :student_programs, :catalog_id, :integer
    add_index :student_programs, :catalog_id
    add_column :catalogs, :main, :boolean, default: false
  end
end
