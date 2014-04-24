require 'entity'
module GraphParser
  module Entities
    class Program < Entity

      attr_accessor :p_modules
      attr_accessor :courses
      
      def initialize(name)
        super(name)
        @p_modules = {}
        @courses = {}
      end

      def add_course(id, course)
        @courses[id] = course
      end

      def add_p_module(id, p_module)
        @p_modules[id] = p_module
      end
    end
  end
end
