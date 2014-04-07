class Pick < ActiveRecord::Base
	has_one :user_catalog
	has_one :pick
end
