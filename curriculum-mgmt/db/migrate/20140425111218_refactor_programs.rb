class RefactorPrograms < ActiveRecord::Migration
  def change
    create_table :courses_programs, id: false do |t|
      t.references :program, index: true
      t.references :course, index: true
    end

    create_table :p_modules_programs, id: false do |t|
      t.references :program, index: true
      t.references :p_module, index: true
    end
  end
end
