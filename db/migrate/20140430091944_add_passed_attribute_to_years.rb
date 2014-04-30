class AddPassedAttributeToYears < ActiveRecord::Migration
  def change
    add_column :years, :passed, :boolean
  end
end
