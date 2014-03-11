class CreateConstraintSets < ActiveRecord::Migration
  def change
    create_table :constraint_sets do |t|
      t.string :name
      t.references :constraint, index: true

      t.timestamps
    end
  end
end
