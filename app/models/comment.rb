class Comment < ActiveRecord::Base
  belongs_to :student_program

  validates :content, presence: true
end
