require 'entity'
module GraphParser
  module Entities
    class Course < Entity

      def print
        p "COURSE : "+@name + "<"+@id.to_s+">"
      end
    end
  end
end