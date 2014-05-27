require_relative '../entity'
module ConstraintsChecker
  module Entities
    class PModule < Entity

      def initialize(properties)
        super(properties)
      end

      
      def find_course(course_id)
        self.find_children(course_id, ConstraintsChecker::Entities::Course.name)
      end
    end
  end
end