class Semester < ActiveRecord::Base
  has_and_belongs_to_many :courses
  belongs_to :year
  validates_inclusion_of :slot, :in => 1..2
end
