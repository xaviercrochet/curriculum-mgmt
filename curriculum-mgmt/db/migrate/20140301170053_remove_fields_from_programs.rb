class RemoveFieldsFromPrograms < ActiveRecord::Migration
  def change
  	remove_column :programs, :cycle
  	remove_column :programs, :program_type
  	remove_column :programs, :credits
  end
end
