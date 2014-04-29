class Semester < ActiveRecord::Base
  has_and_belongs_to_many :courses
  has_one :slot
  belongs_to :year
end
