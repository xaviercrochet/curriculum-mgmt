class AddGraphToCatalog < ActiveRecord::Migration
  def change
    add_attachment :catalogs, :graph
  end
end
