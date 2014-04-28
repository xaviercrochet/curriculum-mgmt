class RefactorPModules < ActiveRecord::Migration
  def change
    drop_table :sub_modules
    add_column :p_modules, :parent_id, :integer
    add_index :p_modules, :parent_id

  end
end
