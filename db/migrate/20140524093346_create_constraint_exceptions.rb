class CreateConstraintExceptions < ActiveRecord::Migration
  def change
    create_table :constraint_exceptions do |t|
      t.references :justification
      t.string :message
      t.references :entity, polymorphic: true
      t.boolean :completed, default: false
      t.string :constraint_type
      t.timestamps
    end
  end
end
