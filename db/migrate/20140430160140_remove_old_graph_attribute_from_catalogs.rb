class RemoveOldGraphAttributeFromCatalogs < ActiveRecord::Migration
  def change
    remove_column :catalogs, :filename
  end
end
