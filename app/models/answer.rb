class Answer < ActiveRecord::Base
  belongs_to :justification
  validates :content, presence: true
  belongs_to :user

  scope :unread, -> {where("read = ?", false)}
  scope :read, -> {where("read= ?", true)}
  scope :from, -> (user) {where("user_id = ?", user.id)}
  scope :not_from, -> (user) {where("user_id != ?", user.id)}
end
