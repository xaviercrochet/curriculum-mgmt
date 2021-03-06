class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.references :justification
      t.string :content
      t.references :user
      t.boolean :read, default: false
      t.timestamps
    end
  end
end
