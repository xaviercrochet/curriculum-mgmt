class PModule < ActiveRecord::Base
  belongs_to :program
  has_many :courses, dependent: :destroy
end
