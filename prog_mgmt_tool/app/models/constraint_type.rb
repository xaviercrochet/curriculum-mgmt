class ConstraintType < ActiveRecord::Base
	has_many :constraints
	before_save {
		self.name = name.upcase
	}

		def self.create_constraint_type(type)
		c_type = ConstraintType.where(:name => type).first
		if c_type.nil?
			c_type = ConstraintType.create(:name => type)
		end
		c_type
	end
end
