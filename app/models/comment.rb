class Comment < ActiveRecord::Base
  belongs_to :student_program
  has_many :answers
  validates :content, presence: true

  scope :unread, -> {where("read = ?", false)}
  scope :read, -> {where("read = ?", true)}

  
end
