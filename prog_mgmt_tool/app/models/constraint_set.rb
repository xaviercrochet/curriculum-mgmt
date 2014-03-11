class ConstraintSet < ActiveRecord::Base
	before_save {
		self.name = name.upcase
	}
end
