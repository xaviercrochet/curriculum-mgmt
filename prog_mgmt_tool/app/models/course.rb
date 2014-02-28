class Course < ActiveRecord::Base
  belongs_to :block, polymorphic: true
  has_many :course_entities, dependent: :destroy
  has_many :course_constraints, dependent: :destroy
  has_many :constraints, dependent: :destroy
  before_save {
  	self.sigle = sigle.upcase
  }
end
