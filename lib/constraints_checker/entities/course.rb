require 'entity'
module ConstraintsChecker
  module Entities
    class Course < Entity

      def count_credits
        return self.credits.to_i
      end

      def find_course(course_id)
        return search(course_id, ConstraintsChecker::Entities::Course.name)
      end
    end
  end
end