class Course < ActiveRecord::Base
  belongs_to :p_module
  has_many :course_entities, dependent: :destroy
  has_many :course_constraints, dependent: :destroy
  before_save {
  	self.sigle = sigle.upcase
  }
end
