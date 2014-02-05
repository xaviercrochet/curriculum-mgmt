class Program < ActiveRecord::Base
	has_many :course_constraints
	has_many :pmodules
	before_save { 
		self.cycle = cycle.upcase 
		self.program_type = program_type.upcase
	}
end
