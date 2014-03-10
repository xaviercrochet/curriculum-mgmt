class CreateCatalogs < ActiveRecord::Migration
  def change
    create_table :catalogs do |t|
      t.string :faculty
      t.string :department
      t.string :ss_filename
      t.timestamps
    end
  end
end
