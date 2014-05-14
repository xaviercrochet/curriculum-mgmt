class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :student_programs, dependent: :destroy
  belongs_to :catalog

  after_create :set_catalog

private
  def set_catalog
    main = Catalog.main.first
    if ! main.nil?
      self.catalog = main
    else
      self.catalog = Catalog.first
    end
    self.save
  end
end
