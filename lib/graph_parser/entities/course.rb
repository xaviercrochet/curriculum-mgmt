require_relative 'entity'
module GraphParser
  module Entities
    class Course
      attr_accessor :id
      attr_accessor :name
      attr_accessor :node
      attr_accessor :constraints
      attr_accessor :real_id

      def initialize(id, name)
        @id = id
        @name = name
        @constraints = []
      end

      def add_constraint(constraint)
        @constraints << constraint
      end

      def print
        p "COURSE : "+@name + "<"+@id.to_s+">"
      end
    end
  end
end