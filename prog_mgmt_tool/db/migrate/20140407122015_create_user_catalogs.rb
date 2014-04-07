class CreateUserCatalogs < ActiveRecord::Migration
  def change
    create_table :user_catalogs do |t|
    	t.references :user, index: true
      t.timestamps
    end
  end
end
