class Semester < ActiveRecord::Base
  has_and_belongs_to_many :courses
  belongs_to :year



  def get_courses_objects(start_year, end_year)
    courses = []
    self.courses.includes(:properties).each do |course|
      courses << course.get_course_object(start_year, end_year)
    end
    return courses
  end

  def get_old_course_objects(start_year, end_year)
    courses = []
    self.courses.includes(:properties).each do |course|
      courses << course.get_old_course_object(start_year, end_year)
    end
    return courses
  end

  def course_present?(course)
    self.courses.where(id: course.id).count > 0
  end

  def get_courses_objects_for_migrated_program(program, start_year, end_year)
    results = []
    courses = coresponding_courses(program)
    courses.each do |course|
      results << course.get_course_object(start_year, end_year)
    end
    return results
  end

  def get_old_course_objects_for_migrated_program(program, start_year, end_year)
    results = []
    courses = coresponding_courses(program)
    courses.each do |course|
      results << course.get_old_course_object(start_year, end_year)
    end
    return results
  end

  def coresponding_courses(program)
    p "looking for coresponding_courses ..."
    p program.catalog.id.to_s
    courses = []
    self.courses.each do |course|
      migrated_course = Course.includes(:properties).find_by_property("SIGLE", course.name, program.catalog)
      courses << migrated_course unless migrated_course.nil?
    end
    return courses 
  end

  def migrate(catalog)
    p  "migrating semester"
    new_courses = []
    courses_not_found = []
    self.courses.includes(:properties).each do |course|
      new_course = Course.find_by_property("SIGLE", course.name, catalog)
      if new_course.nil?
         courses_not_found << course
      else
        new_courses << new_course
      end
    end

    self.courses = new_courses
    return courses_not_found
  end

  def count_credits
    result = 0
    self.courses.each do |course|
      result += course.credits.to_i
    end
    return result
  end
end
