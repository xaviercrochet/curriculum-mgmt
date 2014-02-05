class ChangeCourseEntityYearTypeField < ActiveRecord::Migration
  def change
  	change_column :course_entities, :year, :string
  end
end
