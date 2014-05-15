class Answer < ActiveRecord::Base
  belongs_to :comment
  validates :content, presence: true
  belongs_to :user

  scope :unread, -> {where("read = ?", false)}
  scope :read, -> {where("read= ?", true)}
end
