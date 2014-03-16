class Constraint < ActiveRecord::Base
  belongs_to :constraint_type
  belongs_to :constraint_set
  belongs_to :course

  before_save {
  	self.role = role.upcase
  }

end
