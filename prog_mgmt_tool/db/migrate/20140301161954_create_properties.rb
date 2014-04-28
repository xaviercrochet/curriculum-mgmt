class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.string :p_type
      t.string :value
      t.references :entity, polymorphic: true
      t.timestamps
    end
  end
end
