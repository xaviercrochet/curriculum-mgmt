class CreateUserCatalogs < ActiveRecord::Migration
  def change
    create_table :user_catalogs do |t|

      t.timestamps
    end
  end
end
