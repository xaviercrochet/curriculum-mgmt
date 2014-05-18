class Justification < ActiveRecord::Base
  belongs_to :student_program
  has_many :answers, dependent: :destroy
  validates :content, presence: true

  scope :unread, -> {where("read = ?", false)}
  scope :read, -> {where("read = ?", true)}



  # tag justification and all the answer he get to read when user responds. 
  def tag_as_read(user)
    self.read = true
    self.save
    self.answers.each do |a|
      a.read = true unless a.user_id.eql? user.id #we don't to tag as read his answers
      a.save
    end
  end

  
end
