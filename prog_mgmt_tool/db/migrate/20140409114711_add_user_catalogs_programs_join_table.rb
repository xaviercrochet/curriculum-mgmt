class AddUserCatalogsProgramsJoinTable < ActiveRecord::Migration
    def change
  	  create_table :programs_user_catalogs, :id => false do |t|
  		t.references :user_catalog, index: true
  		t.references :programs, index: true
  	end
  end
end
