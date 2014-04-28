class CreatePrograms < ActiveRecord::Migration
  def change
    create_table :programs do |t|
      t.string :cycle
      t.string :type
      t.integer :credits

      t.timestamps
    end
  end
end
