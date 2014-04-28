class RemoveFieldsFromCourses < ActiveRecord::Migration
  def change
  	remove_column :courses, :name
  	remove_column :courses, :sigle
  end
end
