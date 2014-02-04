class CreatePModules < ActiveRecord::Migration
  def change
    create_table :p_modules do |t|
      t.string :name
      t.string :module_type
      t.integer :credits
      t.references :program, index: true

      t.timestamps
    end
  end
end
