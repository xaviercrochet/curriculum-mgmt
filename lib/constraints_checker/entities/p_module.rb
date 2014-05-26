require_relative '../entity'
module ConstraintsChecker
  module Entities
    class PModule < Entity
      def find_course(id)
        self.find_children(id, ConstraintsChecker::Entities::Course.name)
      end
    end
  end
end