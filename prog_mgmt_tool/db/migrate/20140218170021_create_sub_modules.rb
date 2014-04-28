class CreateSubModules < ActiveRecord::Migration
  def change
    create_table :sub_modules do |t|
      t.string :name
      t.references :p_module, index: true
      t.references :catalog, index: true

      t.timestamps
    end
  end
end
