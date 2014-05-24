class Justification < ActiveRecord::Base
  belongs_to :student_program
  has_many :answers, dependent: :destroy
  has_many :constraint_exceptions, dependent: :destroy

  scope :unread, -> {where("read = ?", false)}
  scope :read, -> {where("read = ?", true)}
  accepts_nested_attributes_for :constraint_exceptions


  def has_uncompleted_exceptions?
    self.constraint_exceptions.count >= 0
  end

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
