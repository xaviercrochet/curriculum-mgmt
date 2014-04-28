class AddCatalogIdToPrograms < ActiveRecord::Migration
  def change
    add_column :programs, :catalog_id, :integer
  end
end
