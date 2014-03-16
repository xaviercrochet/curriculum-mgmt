class ConstraintType < ActiveRecord::Base
	has_many :constraints
	before_save {
		self.name = name.upcase
	}
end
