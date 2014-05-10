class AddUserIdToConcernedModel < ActiveRecord::Migration
  def change
    add_column :student_programs, :user_id, :integer
  end
end
