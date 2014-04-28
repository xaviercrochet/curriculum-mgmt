class RemoveFieldsFromSubModules < ActiveRecord::Migration
  def change
  	remove_column :sub_modules, :name
  end
end
