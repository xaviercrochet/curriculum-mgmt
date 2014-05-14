class Comment < ActiveRecord::Base
  belongs_to :student_program
  has_many :answers
  validates :content, presence: true
end
