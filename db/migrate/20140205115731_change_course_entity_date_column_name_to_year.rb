class ChangeCourseEntityDateColumnNameToYear < ActiveRecord::Migration
  def change
  	rename_column :course_entities, :date, :year
  end
end
