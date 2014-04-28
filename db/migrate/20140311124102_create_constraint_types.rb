class CreateConstraintTypes < ActiveRecord::Migration
  def change
    create_table :constraint_types do |t|
      t.string :name
      t.references :catalog, index: true
			t.timestamps
    end
  end
end
