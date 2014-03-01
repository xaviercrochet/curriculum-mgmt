class Program < ActiveRecord::Base
	has_many :p_modules, dependent: :destroy
	has_many :properties, as: :entity, dependent: :destroy
	has_many :courses, as: :block, dependent: :destroy
	belongs_to :catalog
end
