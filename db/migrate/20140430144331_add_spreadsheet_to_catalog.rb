class AddSpreadsheetToCatalog < ActiveRecord::Migration
  def change
    add_attachment :catalogs, :spreadsheet
  end
end
