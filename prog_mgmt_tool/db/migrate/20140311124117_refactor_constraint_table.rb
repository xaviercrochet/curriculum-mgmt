class RefactorConstraintTable < ActiveRecord::Migration
  def change
  	remove_column :constraints, :set_type
  	remove_column :constraints, :constraint_type
  	remove_column :constraints, :set_id
  	add_column :constraints, :constraint_set_id, :integer
  	add_index :constraints, :constraint_set_id
  	add_column :constraints, :constraint_type_id, :integer
  	add_index :constraints, :constraint_type_id
  end
end
