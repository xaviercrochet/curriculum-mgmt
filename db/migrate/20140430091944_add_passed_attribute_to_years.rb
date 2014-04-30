class AddPassedAttributeToYears < ActiveRecord::Migration
  def change
    add_column :years, :passed, :boolean, default: true
  end
end
