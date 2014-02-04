class User < ActiveRecord::Base
	before_save { self.email = email.downcase }
	validates :name, presence: true, length: {maximum: 42}
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@student.uclouvain.be\z/i
	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: true
	has_secure_password
	validates :password, length: { minimum: 6}
end
