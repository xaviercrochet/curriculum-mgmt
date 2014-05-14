class AddCatalogIdtoUsertable < ActiveRecord::Migration
  def change
    add_column :users, :catalog_id, :integer
    add_index :users, :catalog_id
  end
end
