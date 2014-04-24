require 'entity'
module GraphParser
  module Entities
    class Course < Entity

      def print
        p "COURSE : "+@name
      end
    end
  end
end