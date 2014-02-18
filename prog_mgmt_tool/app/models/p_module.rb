class PModule < ActiveRecord::Base
  belongs_to :program
  has_many :courses, as: :block, dependent: :destroy
  has_many :sub_modules, dependent: :destroy
end
