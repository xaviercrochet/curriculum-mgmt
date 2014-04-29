class StudentProgram < ActiveRecord::Base
  belongs_to :program
  has_many :years, dependent: :destroy
end
