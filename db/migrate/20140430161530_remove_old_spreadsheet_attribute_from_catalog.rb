class RemoveOldSpreadsheetAttributeFromCatalog < ActiveRecord::Migration
  def change
    remove_column :catalogs, :ss_filename
  end
end
