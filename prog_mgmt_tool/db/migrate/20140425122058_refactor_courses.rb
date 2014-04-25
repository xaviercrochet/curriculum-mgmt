class RefactorCourses < ActiveRecord::Migration
  def change
    remove_column :courses, :block_id
    remove_column :courses, :block_type
    add_column :courses, :p_module_id, :integer
    add_index :courses, :p_module_id
  end
end
