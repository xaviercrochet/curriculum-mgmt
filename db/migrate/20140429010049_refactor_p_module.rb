class RefactorPModule < ActiveRecord::Migration
  def change
    add_index :p_modules, :parent_id
    remove_column :p_modules, :program_id
  end
end
