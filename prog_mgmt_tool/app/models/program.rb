class Program < ActiveRecord::Base
	has_many :p_modules, dependent: :destroy
	has_many :courses, dependent: :destroy
	belongs_to :catalog
	before_save { 
		self.cycle = cycle.upcase 
		self.program_type = program_type.upcase
	}
end
