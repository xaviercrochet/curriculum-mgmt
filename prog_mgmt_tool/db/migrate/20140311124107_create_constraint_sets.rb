class CreateConstraintSets < ActiveRecord::Migration
  def change
    create_table :constraint_sets do |t|
      t.timestamps
      t.references :constraint_set_type, index: true
    end
  end
end
