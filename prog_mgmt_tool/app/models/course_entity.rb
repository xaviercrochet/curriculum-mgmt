class CourseEntity < ActiveRecord::Base
  belongs_to :course
  belongs_to :semester
  before_save :compute_url

  def compute_url
  	self.url = "http://www.uclouvain.be/cours-"+self.year+"-"+self.course.sigle
  end
end
