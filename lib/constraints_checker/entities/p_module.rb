require_relative '../entity'
module ConstraintsChecker
  module Entities
    class PModule < Entity
      def find_course(course_id)
        @childrens.each do |children|
          if children.class.name.eql? "ConstraintsChecker::Entities::Course" and children.id.eql? course_id.to_s
            return children
          end
        end
        return nil
      end
    end
  end
end