class RemoveFieldsFromPModules < ActiveRecord::Migration
  def change
  	remove_column :p_modules, :name
  	remove_column :p_modules, :module_type
  	remove_column :p_modules, :credits
  end
end
