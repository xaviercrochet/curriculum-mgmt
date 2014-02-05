class Course < ActiveRecord::Base
  belongs_to :pmodule
  has_many :course_entities, dependent: :destroy
  before_save {
  	self.sigle = sigle.upcase
  }
end
