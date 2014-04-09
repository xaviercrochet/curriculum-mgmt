class AddUserCatalogsSubModulesJoinTable < ActiveRecord::Migration
  def change
  	  create_table :sub_modules_user_catalogs, :id => false do |t|
  		t.references :user_catalog, index: true
  		t.references :sub_modules, index: true
  	end
  end
end
