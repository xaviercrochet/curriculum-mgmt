class AcademicYear < ActiveRecord::Base

  has_many :catalogs
  validates :start_year, presence: true
  validates :end_year, presence: true
end
