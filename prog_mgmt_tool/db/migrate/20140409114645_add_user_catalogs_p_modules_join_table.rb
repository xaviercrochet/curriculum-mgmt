class AddUserCatalogsPModulesJoinTable < ActiveRecord::Migration
  def change
  	  create_table :p_modules_user_catalogs, :id => false do |t|
  		t.references :user_catalog, index: true
  		t.references :p_modules, index: true
  	end
  end
end
