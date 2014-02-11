class CreateCatalogs < ActiveRecord::Migration
  def change
    create_table :catalogs do |t|
      t.string :faculty
      t.string :department

      t.timestamps
    end
  end
end
