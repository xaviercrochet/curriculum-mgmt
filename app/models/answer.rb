class Answer < ActiveRecord::Base
  belongs_to :comment
  validates :content, presence: true
  belongs_to :user
end
