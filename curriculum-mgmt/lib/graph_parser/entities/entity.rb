require_relative 'course'

module GraphParser
  class Entity
    attr_accessor :name
    attr_accessor :id
    attr_accessor :node
    attr_accessor :courses
    
    def initialize(id, name)
      @name = name
      @id = id
      @courses = []
    end


    def add_course(course)
        @courses << course
    end


    def count_courses
      result = @courses.size

      @p_modules.each do |m|
        result = result + m.count_courses
      end
      return result
    end

    def print
      p "MODULE : " + @name
      @p_modules.each do |m|
        m.print
      end
      @courses.each do |m|
        m.print
      end
    end

  end
end