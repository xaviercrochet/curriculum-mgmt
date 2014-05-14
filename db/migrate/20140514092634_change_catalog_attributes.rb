class ChangeCatalogAttributes < ActiveRecord::Migration
  def change
    remove_column :catalogs, :faculty
    remove_column :catalogs, :department
    add_column :catalogs, :academic_year_id, :integer
    add_column :catalogs, :name, :string
    add_index :catalogs, :academic_year_id
    add_column :catalogs, :version, :integer, default: 0
  end

end
