class Constraint < ActiveRecord::Base
  belongs_to :catalog
  belongs_to :course

  before_save {
  	self.constraint_type = constraint_type.upcase
  	self.role = role.upcase
  	self.set_type = set_type.upcase
  }

end
