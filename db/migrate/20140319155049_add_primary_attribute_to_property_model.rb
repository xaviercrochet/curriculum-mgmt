class AddPrimaryAttributeToPropertyModel < ActiveRecord::Migration
  def change
    add_column :properties, :primary, :boolean, :default => false
  end
end
