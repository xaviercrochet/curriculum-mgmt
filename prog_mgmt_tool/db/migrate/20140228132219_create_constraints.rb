class CreateConstraints < ActiveRecord::Migration
  def change
    create_table :constraints do |t|
      t.references :catalog, index: true
      t.references :entity, polymorphic: true
      t.integer :set_id
      t.string :set_type
      t.string :role
      t.string :constraint_type

      t.timestamps
    end
  end
end
