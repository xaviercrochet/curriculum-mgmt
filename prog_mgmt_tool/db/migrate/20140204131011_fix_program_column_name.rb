class FixProgramColumnName < ActiveRecord::Migration
	def self.up
		rename_column :programs, :type, :program_type
	end

	def self.down
		rename_column :programs, :program_type, :type
	end
end