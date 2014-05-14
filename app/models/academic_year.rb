class AcademicYear < ActiveRecord::Base

  has_many :catalogs
  validates :start_year, presence: true
  validates :end_year, presence: true


  def name
    self.start_year.to_s + " - " + self.end_year.to_s
  end
end
