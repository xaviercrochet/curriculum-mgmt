class RefactorConstraints < ActiveRecord::Migration
  def change
    remove_column :constraints, :entity_id
    remove_column :constraints, :entity_type
    remove_column :constraints, :role
    add_column :constraints, :course_id, :integer
    add_index :constraints, :course_id
    # add_column :course, :target_id, :integer
    # add_index :course, :target_id

    create_table :constraints_courses, id: false do |t|
      t.references :course, index: true
      t.references :constraint, index: true
    end
  end
end
