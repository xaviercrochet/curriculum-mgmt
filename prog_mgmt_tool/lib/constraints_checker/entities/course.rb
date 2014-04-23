require 'entity'
module ConstraintsChecker
  module Entities
    class Course < Entity

      def count_credits
        return self.credits.to_i
      end
    end
  end
end