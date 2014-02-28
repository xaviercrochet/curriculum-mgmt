class Constraint < ActiveRecord::Base
  belongs_to :catalog
  belongs_to :course

  after_create :set_id
  before_save {
  	self.constraint_type.upcase
  	self.role.upcase
  }


  private
  	
  	def set_id
  		
  		if Constraint.count == 0
  			self.set_id = 0
  		
  		else
  			self.set_id = Constraint.last.set_id + 1
  		end
  		self.save 
  	end


end
