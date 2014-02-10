class Course < ActiveRecord::Base
  belongs_to :pmodule
  belongs_to :program
  has_many :course_entities, dependent: :destroy
  has_many :course_constraints, dependent: :destroy
  before_save {
  	self.sigle = sigle.upcase
  }
end
