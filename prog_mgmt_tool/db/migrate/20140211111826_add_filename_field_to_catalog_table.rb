class AddFilenameFieldToCatalogTable < ActiveRecord::Migration
  def change
    add_column :catalogs, :filename, :string
  end
end
