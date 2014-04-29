class Year < ActiveRecord::Base
  belongs_to :student_program
  has_one :first_semester, class_name: 'Semester'
  has_one :second_semester, class_name: 'Semester'
end
