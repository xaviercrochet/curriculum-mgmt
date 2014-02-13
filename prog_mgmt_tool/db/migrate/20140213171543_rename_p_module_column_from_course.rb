class RenamePModuleColumnFromCourse < ActiveRecord::Migration
  def change
  	rename_column :courses, :pmodule_id, :p_module_id
  end
end
