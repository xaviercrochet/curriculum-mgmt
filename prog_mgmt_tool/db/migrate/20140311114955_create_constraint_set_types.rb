class CreateConstraintSetTypes < ActiveRecord::Migration
  def change
    create_table :constraint_set_types do |t|
      t.string :name
      t.references :catalog, index: true
      t.timestamps
    end
  end
end
