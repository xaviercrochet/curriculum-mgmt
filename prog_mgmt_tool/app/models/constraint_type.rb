class ConstraintType < ActiveRecord::Base
	before_save {
		self.name = name.upcase
	}
end
