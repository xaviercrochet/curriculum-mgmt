class AddUserCatalogsCoursesJoinTable < ActiveRecord::Migration
  def change
  	create_table :courses_user_catalogs, :id => false do |t|
  		t.references :user_catalog, index: true
  		t.references :course, idnex: true
  	end
  end
end
