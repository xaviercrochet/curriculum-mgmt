require_relative '../entity'
module ConstraintsChecker
  module Entities
    class Course < Entity


      # compare academic year of courses.
      def compare(course)
        if self.start_year.to_i > course.start_year.to_i
          return 1
        elsif self.start_year.to_i == course.start_year.to_i
          return 0
        else
          return -1
        end
      end

      def count_credits
        return self.credits.to_i
      end

      def find_course(course_id)
        return search(course_id, self.class.name)
      end
    end
  end
end