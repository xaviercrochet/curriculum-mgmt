class UserCatalog < ActiveRecord::Base
	has_many :picks
	has_many :courses, through: :picks
end
